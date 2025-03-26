"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Loader2, Send } from "lucide-react"
import { getStudents } from "@/lib/services/student-service"
import { getTeachers } from "@/lib/services/teacher-service"
import { sendBulkNotifications } from "@/lib/services/notification-service"

export function NotificationCenter() {
  const [title, setTitle] = useState("")
  const [message, setMessage] = useState("")
  const [recipientType, setRecipientType] = useState("all")
  const [selectedClass, setSelectedClass] = useState("")
  const [students, setStudents] = useState([])
  const [teachers, setTeachers] = useState([])
  const [loading, setLoading] = useState(true)
  const [sending, setSending] = useState(false)

  useEffect(() => {
    fetchUsers()
  }, [])

  const fetchUsers = async () => {
    try {
      setLoading(true)
      const [studentsData, teachersData] = await Promise.all([getStudents(), getTeachers()])

      setStudents(studentsData)
      setTeachers(teachersData)
    } catch (error) {
      console.error("Error fetching users:", error)
    } finally {
      setLoading(false)
    }
  }

  const handleSendNotification = async () => {
    if (!title || !message) {
      alert("Please enter both title and message")
      return
    }

    try {
      setSending(true)

      let recipientIds = []

      if (recipientType === "all") {
        // Send to all students
        recipientIds = students.map((student) => student.id)
      } else if (recipientType === "class" && selectedClass) {
        // Send to students in selected class
        recipientIds = students.filter((student) => student.classId === selectedClass).map((student) => student.id)
      }

      if (recipientIds.length === 0) {
        alert("No recipients selected")
        return
      }

      await sendBulkNotifications(recipientIds, {
        title,
        message,
        type: "admin",
      })

      alert(`Notification sent to ${recipientIds.length} recipients`)

      // Reset form
      setTitle("")
      setMessage("")
    } catch (error) {
      console.error("Error sending notifications:", error)
      alert("Failed to send notifications")
    } finally {
      setSending(false)
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Notification Center</CardTitle>
        <CardDescription>Send notifications to students and teachers</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="grid gap-6">
          <div className="grid gap-2">
            <label htmlFor="recipient-type">Recipient</label>
            <Select value={recipientType} onValueChange={setRecipientType}>
              <SelectTrigger>
                <SelectValue placeholder="Select recipients" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Students</SelectItem>
                <SelectItem value="class">Students in Class</SelectItem>
              </SelectContent>
            </Select>
          </div>

          {recipientType === "class" && (
            <div className="grid gap-2">
              <label htmlFor="class-select">Select Class</label>
              <Select value={selectedClass} onValueChange={setSelectedClass}>
                <SelectTrigger>
                  <SelectValue placeholder="Select a class" />
                </SelectTrigger>
                <SelectContent>
                  {/* In a real app, we would fetch classes here */}
                  <SelectItem value="class1">Class 1</SelectItem>
                  <SelectItem value="class2">Class 2</SelectItem>
                </SelectContent>
              </Select>
            </div>
          )}

          <div className="grid gap-2">
            <label htmlFor="notification-title">Title</label>
            <Input
              id="notification-title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Notification title"
            />
          </div>

          <div className="grid gap-2">
            <label htmlFor="notification-message">Message</label>
            <Textarea
              id="notification-message"
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              placeholder="Enter your message here"
              rows={4}
            />
          </div>

          <Button
            onClick={handleSendNotification}
            disabled={sending || !title || !message}
            className="flex items-center gap-2"
          >
            {sending ? (
              <>
                <Loader2 className="h-4 w-4 animate-spin" />
                Sending...
              </>
            ) : (
              <>
                <Send className="h-4 w-4" />
                Send Notification
              </>
            )}
          </Button>
        </div>
      </CardContent>
    </Card>
  )
}

