"use client"

import { useState, useEffect } from "react"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { AttendanceView } from "@/components/student/attendance-view"
import { ResultsView } from "@/components/student/results-view"
import { NotificationsView } from "@/components/student/notifications-view"
import { ClipboardCheck, GraduationCap, Bell } from "lucide-react"
import { auth } from "@/lib/firebase"
import { getStudentData } from "@/lib/services/student-service"

export function StudentDashboard() {
  const [studentData, setStudentData] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchStudentData = async () => {
      try {
        const user = auth.currentUser
        if (user) {
          const data = await getStudentData(user.uid)
          setStudentData(data)
        }
      } catch (error) {
        console.error("Error fetching student data:", error)
      } finally {
        setLoading(false)
      }
    }

    fetchStudentData()
  }, [])

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle>Student Dashboard</CardTitle>
          <CardDescription>View your attendance, results, and notifications</CardDescription>
        </CardHeader>
        {studentData && (
          <CardContent>
            <div className="grid gap-2">
              <div className="font-medium">Student ID: {studentData.studentId}</div>
              <div className="font-medium">Name: {studentData.name}</div>
              <div className="font-medium">Class: {studentData.className}</div>
            </div>
          </CardContent>
        )}
      </Card>

      <Tabs defaultValue="attendance">
        <TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="attendance" className="flex items-center gap-2">
            <ClipboardCheck className="h-4 w-4" />
            <span className="hidden sm:inline">Attendance</span>
          </TabsTrigger>
          <TabsTrigger value="results" className="flex items-center gap-2">
            <GraduationCap className="h-4 w-4" />
            <span className="hidden sm:inline">Results</span>
          </TabsTrigger>
          <TabsTrigger value="notifications" className="flex items-center gap-2">
            <Bell className="h-4 w-4" />
            <span className="hidden sm:inline">Notifications</span>
          </TabsTrigger>
        </TabsList>
        <TabsContent value="attendance">
          <AttendanceView studentId={studentData?.studentId} />
        </TabsContent>
        <TabsContent value="results">
          <ResultsView studentId={studentData?.studentId} />
        </TabsContent>
        <TabsContent value="notifications">
          <NotificationsView studentId={studentData?.studentId} />
        </TabsContent>
      </Tabs>
    </div>
  )
}

