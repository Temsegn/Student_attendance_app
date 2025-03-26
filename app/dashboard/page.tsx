"use client"

import { useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import { auth } from "@/lib/firebase"
import { onAuthStateChanged } from "firebase/auth"
import { Button } from "@/components/ui/button"
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { AdminDashboard } from "@/components/dashboard/admin-dashboard"
import { TeacherDashboard } from "@/components/dashboard/teacher-dashboard"
import { StudentDashboard } from "@/components/dashboard/student-dashboard"
import { getUserRole } from "@/lib/services/user-service"
import { Loader2 } from "lucide-react"

export default function Dashboard() {
  const [userRole, setUserRole] = useState(null)
  const [loading, setLoading] = useState(true)
  const router = useRouter()

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        try {
          const role = await getUserRole(user.uid)
          setUserRole(role)
        } catch (error) {
          console.error("Error fetching user role:", error)
        } finally {
          setLoading(false)
        }
      } else {
        router.push("/")
        setLoading(false)
      }
    })

    return () => unsubscribe()
  }, [router])

  const handleLogout = async () => {
    try {
      await auth.signOut()
      router.push("/")
    } catch (error) {
      console.error("Error signing out:", error)
    }
  }

  if (loading) {
    return (
      <div className="flex h-screen items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin" />
      </div>
    )
  }

  return (
    <div className="container py-6">
      <div className="mb-6 flex items-center justify-between">
        <h1 className="text-3xl font-bold">Dashboard</h1>
        <Button variant="outline" onClick={handleLogout}>
          Logout
        </Button>
      </div>

      {userRole === "admin" && <AdminDashboard />}
      {userRole === "teacher" && <TeacherDashboard />}
      {userRole === "student" && <StudentDashboard />}
      {!userRole && (
        <Card>
          <CardHeader>
            <CardTitle>Access Denied</CardTitle>
            <CardDescription>
              Your account has not been assigned a role yet. Please contact the administrator.
            </CardDescription>
          </CardHeader>
        </Card>
      )}
    </div>
  )
}

