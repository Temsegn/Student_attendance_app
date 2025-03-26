"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Loader2, CheckCircle, XCircle } from "lucide-react"
import { getPendingTeachers, approveTeacher, rejectTeacher } from "@/lib/services/teacher-service"

export function PendingVerifications() {
  const [pendingTeachers, setPendingTeachers] = useState([])
  const [loading, setLoading] = useState(true)
  const [processingId, setProcessingId] = useState(null)

  useEffect(() => {
    fetchPendingTeachers()
  }, [])

  const fetchPendingTeachers = async () => {
    try {
      setLoading(true)
      const teachersData = await getPendingTeachers()
      setPendingTeachers(teachersData)
    } catch (error) {
      console.error("Error fetching pending teachers:", error)
    } finally {
      setLoading(false)
    }
  }

  const handleApprove = async (teacherId) => {
    try {
      setProcessingId(teacherId)
      await approveTeacher(teacherId)
      setPendingTeachers((prev) => prev.filter((teacher) => teacher.id !== teacherId))
    } catch (error) {
      console.error("Error approving teacher:", error)
    } finally {
      setProcessingId(null)
    }
  }

  const handleReject = async (teacherId) => {
    try {
      setProcessingId(teacherId)
      await rejectTeacher(teacherId)
      setPendingTeachers((prev) => prev.filter((teacher) => teacher.id !== teacherId))
    } catch (error) {
      console.error("Error rejecting teacher:", error)
    } finally {
      setProcessingId(null)
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Pending Verifications</CardTitle>
        <CardDescription>Approve or reject pending teacher registrations</CardDescription>
      </CardHeader>
      <CardContent>
        {loading ? (
          <div className="flex justify-center py-8">
            <Loader2 className="h-8 w-8 animate-spin" />
          </div>
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Email</TableHead>
                <TableHead>Phone</TableHead>
                <TableHead>Subject</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {pendingTeachers.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={5} className="text-center">
                    No pending verifications
                  </TableCell>
                </TableRow>
              ) : (
                pendingTeachers.map((teacher) => (
                  <TableRow key={teacher.id}>
                    <TableCell>{teacher.name}</TableCell>
                    <TableCell>{teacher.email}</TableCell>
                    <TableCell>{teacher.phone}</TableCell>
                    <TableCell>{teacher.subject}</TableCell>
                    <TableCell className="text-right">
                      <div className="flex justify-end gap-2">
                        <Button
                          variant="outline"
                          size="icon"
                          onClick={() => handleApprove(teacher.id)}
                          disabled={processingId === teacher.id}
                        >
                          {processingId === teacher.id ? (
                            <Loader2 className="h-4 w-4 animate-spin" />
                          ) : (
                            <CheckCircle className="h-4 w-4 text-green-500" />
                          )}
                        </Button>
                        <Button
                          variant="outline"
                          size="icon"
                          onClick={() => handleReject(teacher.id)}
                          disabled={processingId === teacher.id}
                        >
                          {processingId === teacher.id ? (
                            <Loader2 className="h-4 w-4 animate-spin" />
                          ) : (
                            <XCircle className="h-4 w-4 text-red-500" />
                          )}
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        )}
      </CardContent>
    </Card>
  )
}

