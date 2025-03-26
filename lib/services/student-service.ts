import { db, auth } from "@/lib/firebase"
import { collection, doc, getDoc, getDocs, updateDoc, deleteDoc, query, where, setDoc } from "firebase/firestore"
import { createUserWithEmailAndPassword } from "firebase/auth"
import { setUserRole } from "./user-service"

export async function getStudents() {
  try {
    const studentsQuery = query(collection(db, "users"), where("role", "==", "student"))
    const snapshot = await getDocs(studentsQuery)

    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }))
  } catch (error) {
    console.error("Error getting students:", error)
    throw error
  }
}

export async function getStudentsByClass(classId) {
  try {
    const studentsQuery = query(
      collection(db, "users"),
      where("role", "==", "student"),
      where("classId", "==", classId),
    )
    const snapshot = await getDocs(studentsQuery)

    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }))
  } catch (error) {
    console.error("Error getting students by class:", error)
    throw error
  }
}

export async function addStudent(studentData) {
  try {
    // Create user account
    const userCredential = await createUserWithEmailAndPassword(
      auth,
      studentData.email,
      "password123", // Default password, should be changed on first login
    )

    // Add student data to Firestore
    await setDoc(doc(db, "users", userCredential.user.uid), {
      ...studentData,
      role: "student",
      createdAt: new Date(),
    })

    // Set user role
    await setUserRole(userCredential.user.uid, "student")

    return userCredential.user.uid
  } catch (error) {
    console.error("Error adding student:", error)
    throw error
  }
}

export async function updateStudent(studentId, studentData) {
  try {
    await updateDoc(doc(db, "users", studentId), {
      ...studentData,
      updatedAt: new Date(),
    })
  } catch (error) {
    console.error("Error updating student:", error)
    throw error
  }
}

export async function deleteStudent(studentId) {
  try {
    await deleteDoc(doc(db, "users", studentId))
  } catch (error) {
    console.error("Error deleting student:", error)
    throw error
  }
}

export async function getStudentData(studentId) {
  try {
    const studentDoc = await getDoc(doc(db, "users", studentId))

    if (studentDoc.exists()) {
      return studentDoc.data()
    }

    return null
  } catch (error) {
    console.error("Error getting student data:", error)
    throw error
  }
}

