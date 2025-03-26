"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Loader2, CheckCircle2, XCircle, Clock } from "lucide-react"
import { getStudentAttendance } from "@/lib/services/attendance-service"

export function AttendanceView({ studentId }) {
  const [attendance, setAttendance] = useState([])
  const [loading, setLoading] = useState(true)
  const [stats, setStats] = useState({
    present: 0,
    absent: 0,
    late: 0,
    total: 0,
    percentage: 0,
  })

  useEffect(() => {
    if (studentId) {
      fetchAttendance()
    }
  }, [studentId])

  const fetchAttendance = async () => {
    try {
      setLoading(true)
      // Note: In a real app, we would get the classId from the student's data
      // For simplicity, we're passing null to get all attendance records
      const attendanceData = await getStudentAttendance(studentId, null)

      // Sort by date (newest first)
      attendanceData.sort((a, b) => new Date(b.date) - new Date(a.date))

      setAttendance(attendanceData)

      // Calculate statistics
      const present = attendanceData.filter((record) => record.status === "present").length
      const absent = attendanceData.filter((record) => record.status === "absent").length
      const late = attendanceData.filter((record) => record.status === "late").length
      const total = attendanceData.length
      const percentage = total > 0 ? Math.round((present / total) * 100) : 0

      setStats({ present, absent, late, total, percentage })
    } catch (error) {
      console.error("Error fetching attendance:", error)
    } finally {
      setLoading(false)
    }
  }

  const getStatusIcon = (status) => {
    switch (status) {
      case "present":
        return <CheckCircle2 className="h-5 w-5 text-green-500" />
      case "absent":
        return <XCircle className="h-5 w-5 text-red-500" />
      case "late":
        return <Clock className="h-5 w-5 text-yellow-500" />
      default:
        return null
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Attendance Records</CardTitle>
        <CardDescription>View your attendance history</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="grid gap-6">
          <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
            <Card>
              <CardContent className="p-4">
                <div className="text-2xl font-bold">{stats.percentage}%</div>
                <div className="text-xs text-muted-foreground">Attendance Rate</div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4">
                <div className="text-2xl font-bold">{stats.present}</div>
                <div className="text-xs text-muted-foreground">Present</div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4">
                <div className="text-2xl font-bold">{stats.absent}</div>
                <div className="text-xs text-muted-foreground">Absent</div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4">
                <div className="text-2xl font-bold">{stats.late}</div>
                <div className="text-xs text-muted-foreground">Late</div>
              </CardContent>
            </Card>
          </div>

          {loading ? (
            <div className="flex justify-center py-8">
              <Loader2 className="h-8 w-8 animate-spin" />
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Date</TableHead>
                  <TableHead>Class</TableHead>
                  <TableHead>Status</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {attendance.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={3} className="text-center">
                      No attendance records found
                    </TableCell>
                  </TableRow>
                ) : (
                  attendance.map((record, index) => (
                    <TableRow key={index}>
                      <TableCell>{record.date}</TableCell>
                      <TableCell>{record.className || "Class"}</TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          {getStatusIcon(record.status)}
                          <span className="capitalize">{record.status}</span>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          )}
        </div>
      </CardContent>
    </Card>
  )
}

