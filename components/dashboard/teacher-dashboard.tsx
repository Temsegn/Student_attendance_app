"use client"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { ClassManagement } from "@/components/teacher/class-management"
import { AttendanceManagement } from "@/components/teacher/attendance-management"
import { ResultsManagement } from "@/components/teacher/results-management"
import { ReportGeneration } from "@/components/teacher/report-generation"
import { Users, ClipboardCheck, GraduationCap, FileSpreadsheet } from "lucide-react"

export function TeacherDashboard() {
  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle>Teacher Dashboard</CardTitle>
          <CardDescription>Manage classes, attendance, and student results</CardDescription>
        </CardHeader>
      </Card>

      <Tabs defaultValue="classes">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="classes" className="flex items-center gap-2">
            <Users className="h-4 w-4" />
            <span className="hidden sm:inline">Classes</span>
          </TabsTrigger>
          <TabsTrigger value="attendance" className="flex items-center gap-2">
            <ClipboardCheck className="h-4 w-4" />
            <span className="hidden sm:inline">Attendance</span>
          </TabsTrigger>
          <TabsTrigger value="results" className="flex items-center gap-2">
            <GraduationCap className="h-4 w-4" />
            <span className="hidden sm:inline">Results</span>
          </TabsTrigger>
          <TabsTrigger value="reports" className="flex items-center gap-2">
            <FileSpreadsheet className="h-4 w-4" />
            <span className="hidden sm:inline">Reports</span>
          </TabsTrigger>
        </TabsList>
        <TabsContent value="classes">
          <ClassManagement />
        </TabsContent>
        <TabsContent value="attendance">
          <AttendanceManagement />
        </TabsContent>
        <TabsContent value="results">
          <ResultsManagement />
        </TabsContent>
        <TabsContent value="reports">
          <ReportGeneration />
        </TabsContent>
      </Tabs>
    </div>
  )
}

