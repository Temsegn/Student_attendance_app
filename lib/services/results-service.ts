import { db, auth } from "@/lib/firebase"
import { collection, doc, getDoc, getDocs, query, where, writeBatch } from "firebase/firestore"

export async function saveResults(classId, examType, resultsData) {
  try {
    const batch = writeBatch(db)

    // Create a unique ID for the results record (classId_examType)
    const resultsId = `${classId}_${examType}`

    // Set the results record
    batch.set(doc(db, "results", resultsId), {
      classId,
      examType,
      updatedAt: new Date(),
      updatedBy: auth.currentUser.uid,
    })

    // Add individual student results records
    resultsData.forEach((record) => {
      const studentResultsId = `${resultsId}_${record.studentId}`
      batch.set(doc(db, "resultsRecords", studentResultsId), {
        resultsId,
        classId,
        examType,
        studentId: record.studentId,
        score: record.score,
        updatedAt: new Date(),
      })
    })

    await batch.commit()
  } catch (error) {
    console.error("Error saving results:", error)
    throw error
  }
}

export async function getResults(classId, examType) {
  try {
    const resultsId = `${classId}_${examType}`

    // Check if results record exists
    const resultsDoc = await getDoc(doc(db, "results", resultsId))

    if (!resultsDoc.exists()) {
      return [] // No results record for this exam type
    }

    // Get individual student results records
    const recordsQuery = query(collection(db, "resultsRecords"), where("resultsId", "==", resultsId))

    const snapshot = await getDocs(recordsQuery)

    return snapshot.docs.map((doc) => doc.data())
  } catch (error) {
    console.error("Error getting results:", error)
    throw error
  }
}

export async function getStudentResults(studentId, classId) {
  try {
    const recordsQuery = query(
      collection(db, "resultsRecords"),
      where("studentId", "==", studentId),
      where("classId", "==", classId),
    )

    const snapshot = await getDocs(recordsQuery)

    return snapshot.docs.map((doc) => doc.data())
  } catch (error) {
    console.error("Error getting student results:", error)
    throw error
  }
}

export async function getClassResults(classId) {
  try {
    const recordsQuery = query(collection(db, "resultsRecords"), where("classId", "==", classId))

    const snapshot = await getDocs(recordsQuery)

    return snapshot.docs.map((doc) => doc.data())
  } catch (error) {
    console.error("Error getting class results:", error)
    throw error
  }
}

