import { db } from "@/lib/firebase"
import {
  collection,
  doc,
  getDocs,
  addDoc,
  query,
  where,
  orderBy,
  limit,
  writeBatch,
  updateDoc,
} from "firebase/firestore"

export async function getStudentNotifications(studentId) {
  try {
    const notificationsQuery = query(
      collection(db, "notifications"),
      where("studentId", "==", studentId),
      orderBy("timestamp", "desc"),
      limit(20),
    )

    const snapshot = await getDocs(notificationsQuery)

    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }))
  } catch (error) {
    console.error("Error getting student notifications:", error)
    throw error
  }
}

export async function sendNotification(studentId, notification) {
  try {
    const notificationData = {
      studentId,
      ...notification,
      timestamp: new Date(),
      read: false,
    }

    const docRef = await addDoc(collection(db, "notifications"), notificationData)

    return {
      id: docRef.id,
      ...notificationData,
    }
  } catch (error) {
    console.error("Error sending notification:", error)
    throw error
  }
}

export async function sendBulkNotifications(studentIds, notification) {
  try {
    const batch = writeBatch(db)

    studentIds.forEach((studentId) => {
      const notificationData = {
        studentId,
        ...notification,
        timestamp: new Date(),
        read: false,
      }

      const docRef = doc(collection(db, "notifications"))
      batch.set(docRef, notificationData)
    })

    await batch.commit()
  } catch (error) {
    console.error("Error sending bulk notifications:", error)
    throw error
  }
}

export async function markNotificationAsRead(notificationId) {
  try {
    await updateDoc(doc(db, "notifications", notificationId), {
      read: true,
      readAt: new Date(),
    })
  } catch (error) {
    console.error("Error marking notification as read:", error)
    throw error
  }
}

