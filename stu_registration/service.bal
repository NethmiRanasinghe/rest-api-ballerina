import ballerina/http;

service /student on new http:Listener(9000) {

    resource function get students() returns Student[] {
        return studentTable.toArray();
    }

    resource function post students(@http:Payload Student[] studentEntries) 
                                    returns Student[]|ConflictingStudentIdsError {

        string[] conflictingIds = from Student studentEntry in studentEntries
            where studentTable.hasKey(studentEntry.studentId)
            select studentEntry.studentId;

        if conflictingIds.length() > 0 {
            return {
                body: {
                    errmsg: string:'join(" ", "Conflicting Student IDs:", ...conflictingIds)
                }
            };
        } else {
            studentEntries.forEach(studentEntry => studentTable.add(studentEntry));
            return studentEntries;
        }
    }

    resource function get students/[string studentId]() returns Student|InvalidStudentIdError {
        Student? studentEntry = studentTable[studentId];
        if studentEntry is () {
            return {
                body: {
                    errmsg: string `Invalid Student ID: ${studentId}`
                }
            };
        }
        return studentEntry;
    }

    resource function put students/[string studentId](@http:Payload Student updatedStudent) 
                                returns Student|InvalidStudentIdError {
    Student? studentEntry = studentTable[studentId];
    if studentEntry is () {
        return {
            body: {
                errmsg: string `Invalid Student ID: ${studentId}`
            }
        };
    }

    _ = studentTable.remove(studentId);

    studentTable.add(updatedStudent);

    return updatedStudent;
}

    resource function delete students/[string studentId]() returns string|InvalidStudentIdError {
        Student? studentEntry = studentTable[studentId];
        if studentEntry is () {
            return {
                body: {
                    errmsg: string `Invalid Student ID: ${studentId}`
                }
            };
        }
        _ = studentTable.remove(studentId);

        return "Student removed successfully.";
    }
}

public type Student record {|
    readonly string studentId;
    string name;
    int age;
    string department;
    decimal gpa;
|};

public final table<Student> key(studentId) studentTable = table [
    {studentId: "E101", name: "Nethmi Sudeni", age: 20, department: "Computer Eng", gpa: 3.75},
    {studentId: "M102", name: "Jane Perera", age: 22, department: "Mathematics", gpa: 3.85}
];

public type ConflictingStudentIdsError record {|
    *http:Conflict;
    ErrorMsg body;
|};

public type InvalidStudentIdError record {|
    *http:NotFound;
    ErrorMsg body;
|};

public type ErrorMsg record {|
    string errmsg;
|};
