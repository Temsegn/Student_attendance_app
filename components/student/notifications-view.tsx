"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Loader2, Bell } from "lucide-react"
import { getStudentNotifications } from "@/lib/services/notification-service"
import { format } from "date-fns"

export function NotificationsView({ studentId }) {
  const [notifications, setNotifications] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (studentId) {
      fetchNotifications()
    }
  }, [studentId])

  const fetchNotifications = async () => {
    try {
      setLoading(true)
      const notificationsData = await getStudentNotifications(studentId)

      // Sort by date (newest first)
      notificationsData.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))

      setNotifications(notificationsData)
    } catch (error) {
      console.error("Error fetching notifications:", error)
    } finally {
      setLoading(false)
    }
  }

  const getNotificationIcon = (type) => {
    switch (type) {
      case "attendance":
        return <Bell className="h-5 w-5 text-blue-500" />
      case "results":
        return <Bell className="h-5 w-5 text-green-500" />
      default:
        return <Bell className="h-5 w-5 text-gray-500" />
    }
  }

  const formatTimestamp = (timestamp) => {
    if (!timestamp) return ""

    try {
      const date = new Date(timestamp)
      return format(date, "MMM d, yyyy h:mm a")
    } catch (error) {
      return timestamp
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Notifications</CardTitle>
        <CardDescription>View your recent notifications</CardDescription>
      </CardHeader>
      <CardContent>
        {loading ? (
          <div className="flex justify-center py-8">
            <Loader2 className="h-8 w-8 animate-spin" />
          </div>
        ) : (
          <div className="space-y-4">
            {notifications.length === 0 ? (
              <div className="text-center py-8 text-muted-foreground">No notifications found</div>
            ) : (
              notifications.map((notification, index) => (
                <Card key={index} className="overflow-hidden">
                  <CardContent className="p-4">
                    <div className="flex items-start gap-4">
                      <div className="mt-1">{getNotificationIcon(notification.type)}</div>
                      <div className="flex-1">
                        <div className="font-medium">{notification.title}</div>
                        <div className="text-sm text-muted-foreground">{notification.message}</div>
                        <div className="text-xs text-muted-foreground mt-1">
                          {formatTimestamp(notification.timestamp)}
                        </div>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))
            )}
          </div>
        )}
      </CardContent>
    </Card>
  )
}

