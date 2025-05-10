import 'package:flutter_dotenv/flutter_dotenv.dart';

String? environment = dotenv.env['ENVIRONMENT'];

String? apiUrl = dotenv.env['HOST'];
String? apiVersion = dotenv.env['API_VERSION'];
String? apiPath = dotenv.env['API_PATH'];
String? awsKeyId = dotenv.env['AWS_KEY_ID'];
String? awsSecretId = dotenv.env['AWS_SECRET_ID'];
String? uploadImagesApiUrl = dotenv.env['UPLOAD_IMAGES_API_URL'];
String? mapsApiKey = dotenv.env['MAPS_API_KEY'];
String? apiCustomerLoc = '$apiUrl/$apiPath/customers/loc';

String? apiCustomerStatus = '$apiUrl/$apiPath/customers/status';
String? token = dotenv.env['TOKEN'];
