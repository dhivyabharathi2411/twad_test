import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:twad/services/api_setup.dart';
import 'package:twad/services/grievance_service.dart';
import 'package:twad/utils/simple_encryption.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  dotenv.testLoad(fileInput: '''
ENCRYPTION_KEY=smar@nexusglobalsolutions1234567
ENCRYPTION_IV=smar@nexus123456
API_ENCRYPT_ENABLED=false
API_BASE_URL=https://api.tanneer.com/api
''');

  late GrievanceService grievanceService;
  const String testContactNumber = '8787878787'; 

  setUp(() async {
    await SimpleUsage.initialize();
    await SimpleUsage.login(
      authToken: 'test_auth_token',
      userData: {
        'userid': 'test_user_1',
        'contactno': testContactNumber,
      },
    );
    await ApiSetup.initializeApiClient();
  grievanceService = GrievanceService();
  });

  group('Create Grievance Unit Tests', () {
    test('createGrievance returns success for valid grievance data', () async {
      final validGrievanceData = {
        "operator_id": 0,
        "is_edit_public_details": 1,
        "public_name": "Test User",
        "public_contactno": testContactNumber,
        "public_emailid": "test@example.com",
        "public_address": "Test Address, Test City",
        "origin": "Mobile",
        "priority": "High",
        "type_id": 1,
        "district_id": 1,
        "address": "Test Complaint Address",
        "complaint_type_id": 1,
        "complaint_subtype_id": 1,
        "description": "Test grievance description for water supply issue",
        "entry_by": 1,
        "entry_by_type": "public",
        "organisation_id": 1,
      };

      final result = await grievanceService.createGrievance(validGrievanceData);
      
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('success'), true);
      expect(result.containsKey('message'), true);
    });

    test('createGrievance validates contact number format', () async {
      final grievanceDataWithInvalidContact = {
        "operator_id": 0,
        "is_edit_public_details": 1,
        "public_name": "Test User",
        "public_contactno": "123", 
        "public_emailid": "test@example.com",
        "public_address": "Test Address",
        "origin": "Mobile",
        "priority": "High",
        "description": "Test grievance description",
      };

      try {
        await grievanceService.createGrievance(grievanceDataWithInvalidContact);
        fail('Should throw exception for invalid contact number');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('createGrievance handles missing required fields', () async {
      final incompleteGrievanceData = {
        "operator_id": 0,
        "public_contactno": testContactNumber,
      };

      try {
        await grievanceService.createGrievance(incompleteGrievanceData);
        fail('Should throw exception for missing required fields');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('createGrievance validates description field', () async {
      final grievanceDataWithEmptyDescription = {
        "operator_id": 0,
        "is_edit_public_details": 1,
        "public_name": "Test User",
        "public_contactno": testContactNumber,
        "public_emailid": "test@example.com",
        "public_address": "Test Address",
        "origin": "Mobile",
        "priority": "High",
        "type_id": 1,
        "district_id": 1,
        "address": "Test Complaint Address",
        "complaint_type_id": 1,
        "complaint_subtype_id": 1,
        "description": "", 
        "entry_by": 1,
        "entry_by_type": "public",
        "organisation_id": 1,
      };
      try {
        await grievanceService.createGrievance(grievanceDataWithEmptyDescription);
        fail('Should throw exception for empty description');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('Login contact number validation passes for valid number', () async {
      expect(testContactNumber.length, equals(10));
      expect(RegExp(r'^[0-9]+$').hasMatch(testContactNumber), isTrue);
    });

    test('createGrievance with different priorities', () async {
      final priorities = ['Low', 'Medium', 'High', 'Critical'];
      
      for (final priority in priorities) {
        final grievanceData = {
          "operator_id": 0,
          "is_edit_public_details": 1,
          "public_name": "Test User",
          "public_contactno": testContactNumber,
          "public_emailid": "test@example.com",
          "public_address": "Test Address",
          "origin": "Mobile",
          "priority": priority,
          "type_id": 1,
          "district_id": 1,
          "address": "Test Complaint Address",
          "complaint_type_id": 1,
          "complaint_subtype_id": 1,
          "description": "Test grievance with $priority priority",
          "entry_by": 1,
          "entry_by_type": "public",
          "organisation_id": 1,
        };

        final result = await grievanceService.createGrievance(grievanceData);
        
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('success'), true);
      }
    });
  });
}