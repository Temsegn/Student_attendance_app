"use client"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { TeacherManagement } from "@/components/admin/teacher-management"
import { StudentManagement } from "@/components/admin/student-management"
import { ReportGeneration } from "@/components/admin/report-generation"
import { NotificationCenter } from "@/components/admin/notification-center"
import { PendingVerifications } from "@/components/admin/pending-verifications"
import { Users, FileSpreadsheet, Bell, UserCheck } from "lucide-react"

export function AdminDashboard() {
  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle>Admin Dashboard</CardTitle>
          <CardDescription>Manage teachers, students, and system-wide settings</CardDescription>
        </CardHeader>
      </Card>

      <Tabs defaultValue="teachers">
        <TabsList className="grid w-full grid-cols-5">
          <TabsTrigger value="teachers" className="flex items-center gap-2">
            <Users className="h-4 w-4" />
            <span className="hidden sm:inline">Teachers</span>
          </TabsTrigger>
          <TabsTrigger value="students" className="flex items-center gap-2">
            <Users className="h-4 w-4" />
            <span className="hidden sm:inline">Students</span>
          </TabsTrigger>
          <TabsTrigger value="reports" className="flex items-center gap-2">
            <FileSpreadsheet className="h-4 w-4" />
            <span className="hidden sm:inline">Reports</span>
          </TabsTrigger>
          <TabsTrigger value="notifications" className="flex items-center gap-2">
            <Bell className="h-4 w-4" />
            <span className="hidden sm:inline">Notifications</span>
          </TabsTrigger>
          <TabsTrigger value="verifications" className="flex items-center gap-2">
            <UserCheck className="h-4 w-4" />
            <span className="hidden sm:inline">Verifications</span>
          </TabsTrigger>
        </TabsList>
        <TabsContent value="teachers">
          <TeacherManagement />
        </TabsContent>
        <TabsContent value="students">
          <StudentManagement />
        </TabsContent>
        <TabsContent value="reports">
          <ReportGeneration />
        </TabsContent>
        <TabsContent value="notifications">
          <NotificationCenter />
        </TabsContent>
        <TabsContent value="verifications">
          <PendingVerifications />
        </TabsContent>
      </Tabs>
    </div>
  )
}

