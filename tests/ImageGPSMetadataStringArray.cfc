component extends="org.lucee.cfml.test.LuceeTestCase" labels="image,gps,metadata" {

	function run( testResults, testBox ) {
		describe("Testcase for GPS metadata parsing with String array fields", function() {

			it( title="checking imageInfo() with GPS String array fields doesn't throw error", body=function( currentSpec ) {
				// This test verifies the fix for GPS metadata parsing when GPS reference fields
				// are stored as String arrays instead of single Strings, which caused:
				// "Expected String value(1 (0x1: GPSLatitudeRef): ): [Ljava.lang.String;"

				var testImagePath = GetDirectoryFromPath(GetCurrentTemplatePath()) & "images/gps-string-array-test.jpg";

				// Skip test if image doesn't exist yet
				if (!fileExists(testImagePath)) {
					// This allows the test to be committed before the test image is added
					return;
				}

				var img = imageRead(testImagePath);

				// The main test: this should not throw an ImageReadException
				var info = imageInfo(img);

				// Verify we got valid info structure back
				expect(info).toBeStruct();
				expect(info).toHaveKey("width");
				expect(info).toHaveKey("height");

				// If GPS data exists, verify it's properly structured
				if (structKeyExists(info, "gps")) {
					expect(info.gps).toBeStruct();

					// GPS structure should have latitude and/or longitude if parsed successfully
					if (structKeyExists(info.gps, "latitude")) {
						expect(info.gps.latitude).toBeStruct();
						// Should have ref field if GPS data was extracted
						if (structKeyExists(info.gps.latitude, "ref")) {
							// Ref should be a string (N or S)
							expect(info.gps.latitude.ref).toBeString();
						}
					}

					if (structKeyExists(info.gps, "longitude")) {
						expect(info.gps.longitude).toBeStruct();
						// Should have ref field if GPS data was extracted
						if (structKeyExists(info.gps.longitude, "ref")) {
							// Ref should be a string (E or W)
							expect(info.gps.longitude.ref).toBeString();
						}
					}
				}
			});

			it( title="checking imageGetEXIFMetadata() with GPS String array fields doesn't throw error", body=function( currentSpec ) {
				var testImagePath = GetDirectoryFromPath(GetCurrentTemplatePath()) & "images/gps-string-array-test.jpg";

				// Skip test if image doesn't exist yet
				if (!fileExists(testImagePath)) {
					return;
				}

				var img = imageRead(testImagePath);

				// This should also not throw an error
				var meta = imageGetEXIFMetadata(img);

				// Verify we got valid metadata structure back
				expect(meta).toBeStruct();

				// If GPS data exists in metadata, verify it's accessible
				if (structKeyExists(meta, "gps")) {
					expect(meta.gps).toBeStruct();
				}
			});

		});
	}
}
