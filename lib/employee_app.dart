import 'package:flutter/material.dart';
import 'database_helper.dart';

class EmployeeApp extends StatefulWidget {
  const EmployeeApp({super.key});

  @override
  _EmployeeAppState createState() => _EmployeeAppState();
}

class _EmployeeAppState extends State<EmployeeApp> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  List<Map<String, dynamic>> _employeeList = [];

  @override
  void initState() {
    super.initState();
    _refreshEmployeeList();
  }

  /// Refreshes the employee list by retrieving all records from the database
  Future<void> _refreshEmployeeList() async {
    final data = await DatabaseHelper.instance.getAllEmployees();
    setState(() {
      _employeeList = data;
    });
    print("Current Employees: $_employeeList"); // Print the employee list
  }

  /// Adds a new employee record to the database
  Future<void> _addEmployee() async {
  // Print statements to check the values being inserted
  print("Adding Employee: ${_firstNameController.text}, ${_lastNameController.text}, ${_departmentController.text}, ${_salaryController.text}");

    await DatabaseHelper.instance.addEmployee({
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'department': _departmentController.text,
      'salary': int.tryParse(_salaryController.text) ?? 0,
    });

    print("Employee added successfully");
    _refreshEmployeeList();
  }


  /// Deletes an employee record from the database by id
  Future<void> _deleteEmployee(int id) async {
    await DatabaseHelper.instance.deleteEmployee(id);
    _refreshEmployeeList();
  }

  /// Displays grouped employee data by department with total salary
  Future<void> _showGroupedByDepartment() async {
    final data = await DatabaseHelper.instance.getEmployeesGroupedByDepartment();
    for (var item in data) {
      print('Department: ${item['department']}, Total Salary: ${item['total_salary']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: _showGroupedByDepartment,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'First Name')),
            TextField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Last Name')),
            TextField(controller: _departmentController, decoration: const InputDecoration(labelText: 'Department')),
            TextField(controller: _salaryController, decoration: const InputDecoration(labelText: 'Salary'), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addEmployee,
              child: const Text('Add Employee'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _employeeList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${_employeeList[index]['firstName']} ${_employeeList[index]['lastName']}'),
                    subtitle: Text('${_employeeList[index]['department']} - Salary: ${_employeeList[index]['salary']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteEmployee(_employeeList[index]['id']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
