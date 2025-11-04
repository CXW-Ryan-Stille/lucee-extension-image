# GPS String Array Test Image

## Purpose

This directory should contain a test image named `gps-string-array-test.jpg` that exhibits the GPS metadata parsing bug described in the fix.

## The Bug

Some images store GPS reference fields (`GPSLatitudeRef`, `GPSLongitudeRef`) as String arrays instead of single Strings. This caused the error:

```
Expected String value(1 (0x1: GPSLatitudeRef): ): [Ljava.lang.String;
org.apache.commons.imaging.ImageReadException: Expected String value(1 (0x1: GPSLatitudeRef): ): [Ljava.lang.String;
    at org.apache.commons.imaging.formats.tiff.TiffField.getStringValue(TiffField.java:436)
    at org.apache.commons.imaging.formats.tiff.TiffImageMetadata.getGPS(TiffImageMetadata.java:467)
    at org.lucee.extension.image.Metadata.gps(Metadata.java:152)
```

## Test Image Requirements

The test image should:
- Be a JPEG image with GPS EXIF metadata
- Have `GPSLatitudeRef` and/or `GPSLongitudeRef` fields stored as String arrays (not single Strings)
- Trigger the bug in the unfixed version of the code

## Adding the Test Image

To add your problematic image:

```bash
# Copy your image to this directory with the expected name
cp /path/to/your/problematic-image.jpg gps-string-array-test.jpg
```

Or use Claude Code to copy it:
```
Copy my image from /path/to/image.jpg to tests/images/gps-string-array-test.jpg
```

## Running the Test

The test is located in: `tests/ImageGPSMetadataStringArray.cfc`

To run all tests:
```bash
./build.sh
```

The test will automatically skip if the image doesn't exist, allowing the test file to be committed before the image is added.

## Fix Details

The fix was implemented in `source/java/src/org/lucee/extension/image/Metadata.java`:
- Added `getStringValue()` helper method to handle both String and String[] GPS field values
- Wrapped `exifMetadata.getGPS()` in try-catch to gracefully handle malformed GPS data
- Added null checks before processing GPS reference fields
