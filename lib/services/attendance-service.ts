import { db, auth } from "@/lib/firebase"
import { collection, doc, getDoc, getDocs, query, where, writeBatch } from "firebase/firestore"

export async function markAttendance(classId, date, attendanceData) {
  try {
    const batch = writeBatch(db)

    // Create a unique ID for the attendance record (classId_date)
    const attendanceId = `${classId}_${date}`

    // Set the attendance record
    batch.set(doc(db, "attendance", attendanceId), {
      classId,
      date,
      updatedAt: new Date(),
      updatedBy: auth.currentUser.uid,
    })

    // Add individual student attendance records
    attendanceData.forEach((record) => {
      const studentAttendanceId = `${attendanceId}_${record.studentId}`
      batch.set(doc(db, "attendanceRecords", studentAttendanceId), {
        attendanceId,
        classId,
        date,
        studentId: record.studentId,
        status: record.status,
        updatedAt: new Date(),
      })
    })

    await batch.commit()
  } catch (error) {
    console.error("Error marking attendance:", error)
    throw error
  }
}

export async function getAttendanceByDate(classId, date) {
  try {
    const attendanceId = `${classId}_${date}`

    // Check if attendance record exists
    const attendanceDoc = await getDoc(doc(db, "attendance", attendanceId))

    if (!attendanceDoc.exists()) {
      return [] // No attendance record for this date
    }

    // Get individual student attendance records
    const recordsQuery = query(collection(db, "attendanceRecords"), where("attendanceId", "==", attendanceId))

    const snapshot = await getDocs(recordsQuery)

    return snapshot.docs.map((doc) => doc.data())
  } catch (error) {
    console.error("Error getting attendance by date:", error)
    throw error
  }
}

export async function getStudentAttendance(studentId, classId) {
  try {
    const recordsQuery = query(
      collection(db, "attendanceRecords"),
      where("studentId", "==", studentId),
      where("classId", "==", classId),
    )

    const snapshot = await getDocs(recordsQuery)

    return snapshot.docs.map((doc) => doc.data())
  } catch (error) {
    console.error("Error getting student attendance:", error)
    throw error
  }
}

export async function getClassAttendance(classId) {
  try {
    const recordsQuery = query(collection(db, "attendanceRecords"), where("classId", "==", classId))

    const snapshot = await getDocs(recordsQuery)

    return snapshot.docs.map((doc) => doc.data())
  } catch (error) {
    console.error("Error getting class attendance:", error)
    throw error
  }
}

