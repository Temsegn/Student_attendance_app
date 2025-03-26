"use client"

import { Input } from "@/components/ui/input"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Loader2 } from "lucide-react"
import { getTeacherClasses } from "@/lib/services/class-service"
import { getStudentsByClass } from "@/lib/services/student-service"
import { markAttendance, getAttendanceByDate } from "@/lib/services/attendance-service"
import { format } from "date-fns"

export function AttendanceManagement() {
  const [classes, setClasses] = useState([])
  const [selectedClass, setSelectedClass] = useState("")
  const [students, setStudents] = useState([])
  const [attendanceDate, setAttendanceDate] = useState(format(new Date(), "yyyy-MM-dd"))
  const [attendanceData, setAttendanceData] = useState({})
  const [loading, setLoading] = useState(true)
  const [isMarkingAttendance, setIsMarkingAttendance] = useState(false)

  useEffect(() => {
    fetchClasses()
  }, [])

  useEffect(() => {
    if (selectedClass) {
      fetchStudents()
      fetchAttendance()
    }
  }, [selectedClass, attendanceDate])

  const fetchClasses = async () => {
    try {
      setLoading(true)
      const classesData = await getTeacherClasses()
      setClasses(classesData)
      if (classesData.length > 0) {
        setSelectedClass(classesData[0].id)
      }
    } catch (error) {
      console.error("Error fetching classes:", error)
    } finally {
      setLoading(false)
    }
  }

  const fetchStudents = async () => {
    try {
      setLoading(true)
      const studentsData = await getStudentsByClass(selectedClass)
      setStudents(studentsData)
    } catch (error) {
      console.error("Error fetching students:", error)
    } finally {
      setLoading(false)
    }
  }

  const fetchAttendance = async () => {
    try {
      setLoading(true)
      const attendance = await getAttendanceByDate(selectedClass, attendanceDate)

      // Convert array to object with studentId as key
      const attendanceObj = {}
      attendance.forEach((item) => {
        attendanceObj[item.studentId] = item.status
      })

      setAttendanceData(attendanceObj)
    } catch (error) {
      console.error("Error fetching attendance:", error)
    } finally {
      setLoading(false)
    }
  }

  const handleAttendanceChange = (studentId, status) => {
    setAttendanceData((prev) => ({
      ...prev,
      [studentId]: status,
    }))
  }

  const handleSaveAttendance = async () => {
    try {
      setIsMarkingAttendance(true)

      // Convert attendance data object to array
      const attendanceArray = Object.keys(attendanceData).map((studentId) => ({
        studentId,
        status: attendanceData[studentId],
        date: attendanceDate,
        classId: selectedClass,
      }))

      await markAttendance(selectedClass, attendanceDate, attendanceArray)
      alert("Attendance saved successfully!")
    } catch (error) {
      console.error("Error saving attendance:", error)
      alert("Failed to save attendance.")
    } finally {
      setIsMarkingAttendance(false)
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Attendance Management</CardTitle>
        <CardDescription>Mark and manage student attendance</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="grid gap-6">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
            <div className="grid gap-2">
              <label htmlFor="class-select">Select Class</label>
              <Select value={selectedClass} onValueChange={setSelectedClass}>
                <SelectTrigger className="w-[200px]">
                  <SelectValue placeholder="Select a class" />
                </SelectTrigger>
                <SelectContent>
                  {classes.map((cls) => (
                    <SelectItem key={cls.id} value={cls.id}>
                      {cls.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="grid gap-2">
              <label htmlFor="date-select">Date</label>
              <div className="flex items-center gap-2">
                <Input
                  id="date-select"
                  type="date"
                  value={attendanceDate}
                  onChange={(e) => setAttendanceDate(e.target.value)}
                  className="w-[200px]"
                />
              </div>
            </div>
          </div>

          {loading ? (
            <div className="flex justify-center py-8">
              <Loader2 className="h-8 w-8 animate-spin" />
            </div>
          ) : (
            <>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Student ID</TableHead>
                    <TableHead>Name</TableHead>
                    <TableHead>Status</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {students.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={3} className="text-center">
                        No students found in this class
                      </TableCell>
                    </TableRow>
                  ) : (
                    students.map((student) => (
                      <TableRow key={student.id}>
                        <TableCell>{student.studentId}</TableCell>
                        <TableCell>{student.name}</TableCell>
                        <TableCell>
                          <Select
                            value={attendanceData[student.studentId] || ""}
                            onValueChange={(value) => handleAttendanceChange(student.studentId, value)}
                          >
                            <SelectTrigger className="w-[120px]">
                              <SelectValue placeholder="Status" />
                            </SelectTrigger>
                            <SelectContent>
                              <SelectItem value="present">Present</SelectItem>
                              <SelectItem value="absent">Absent</SelectItem>
                              <SelectItem value="late">Late</SelectItem>
                            </SelectContent>
                          </Select>
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>

              {students.length > 0 && (
                <div className="flex justify-end">
                  <Button onClick={handleSaveAttendance} disabled={isMarkingAttendance}>
                    {isMarkingAttendance ? (
                      <>
                        <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                        Saving...
                      </>
                    ) : (
                      "Save Attendance"
                    )}
                  </Button>
                </div>
              )}
            </>
          )}
        </div>
      </CardContent>
    </Card>
  )
}

