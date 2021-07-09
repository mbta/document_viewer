const AWS = require('aws-sdk');
const sharp = require('sharp');

const s3 = new AWS.S3();

exports.handler = async (event, _context, _callback) => {
  // Read options from the event parameter.
  const bucket = event.Records[0].s3.bucket.name;
  // Object key may have spaces or unicode non-ASCII characters.
  const srcKey    = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, " "));

  if (!typeMatch(srcKey)) {
    console.log("Could not determine the image type.");
    return;
  }

  switch (imageType(srcKey)) {
    case "gif":
    case "png":
      await convertToJpg(bucket, srcKey);
      break;
    case "jpeg":
      await copyJpeg(bucket, srcKey);
      break;
    case "jpg":
      console.log("Already a jpg, no need for conversion");
      break;
    default:
      console.log(`Unsupported image type: ${imageType}`);
      break;
  }
};

// Infer the image type from the file suffix.
const typeMatch = (fileName) => fileName.match(/\.([^.]*)$/);

const extension = (fileName) => typeMatch(fileName)[1];

const imageType = (fileName) => extension(fileName).toLowerCase();

const convertToJpg = async (bucket, srcKey) => {
  const dstKey = srcKey.replace(`.${extension(srcKey)}`, ".jpg");

  let originalImage;
  let buffer;
  
  // Download the image from the S3 source bucket. 
  try {
    const srcParams = {
      Bucket: bucket,
      Key: srcKey
    };
    originalImage = await s3.getObject(srcParams).promise();
  } catch (error) {
    console.log(error);
    return;
  }

  // Convert to a high quality jpeg
  try {
    buffer = await sharp(originalImage.Body)
      .jpeg({
        quality: 100,
        chromaSubsampling: '4:4:4'
      })
      .toBuffer();
  } catch (error) {
    console.log(error);
    return;
  }

  // Upload the jpeg image to the destination bucket
  try {
    const dstParams = {
      Bucket: bucket,
      Key: dstKey,
      Body: buffer,
      ContentType: "image/jpeg"
    };
    await s3.putObject(dstParams).promise();
  } catch (error) {
    console.log(error);
    return;
  }

  console.log(`Successfully converted ${bucket}/${srcKey} and uploaded to ${bucket}/${dstKey}`);
};

const copyJpeg = async (bucket, srcKey) => {
  const dstKey = srcKey.replace(".jpeg", ".jpg");
  const params = {
    Bucket: bucket,
    CopySource: `/${bucket}/${srcKey}`,
    Key: dstKey
  }
  
  try {
    await s3.copyObject(params).promise();
  } catch (error) {
    console.log(error);
    return;
  }

  console.log(`Successfully renamed (copied) ${bucket}/${srcKey} to ${bucket}/${dstKey}`);
}
