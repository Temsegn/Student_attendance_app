import { db, auth } from "@/lib/firebase"
import { collection, doc, getDocs, updateDoc, deleteDoc, query, where, setDoc } from "firebase/firestore"
import { createUserWithEmailAndPassword } from "firebase/auth"
import { setUserRole } from "./user-service"

export async function getTeachers() {
  try {
    const teachersQuery = query(collection(db, "users"), where("role", "==", "teacher"))
    const snapshot = await getDocs(teachersQuery)

    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }))
  } catch (error) {
    console.error("Error getting teachers:", error)
    throw error
  }
}

export async function addTeacher(teacherData) {
  try {
    // Create user account
    const userCredential = await createUserWithEmailAndPassword(
      auth,
      teacherData.email,
      "password123", // Default password, should be changed on first login
    )

    // Add teacher data to Firestore
    await setDoc(doc(db, "users", userCredential.user.uid), {
      ...teacherData,
      role: "teacher",
      createdAt: new Date(),
    })

    // Set user role
    await setUserRole(userCredential.user.uid, "teacher")

    return userCredential.user.uid
  } catch (error) {
    console.error("Error adding teacher:", error)
    throw error
  }
}

export async function updateTeacher(teacherId, teacherData) {
  try {
    await updateDoc(doc(db, "users", teacherId), {
      ...teacherData,
      updatedAt: new Date(),
    })
  } catch (error) {
    console.error("Error updating teacher:", error)
    throw error
  }
}

export async function deleteTeacher(teacherId) {
  try {
    await deleteDoc(doc(db, "users", teacherId))
  } catch (error) {
    console.error("Error deleting teacher:", error)
    throw error
  }
}

export async function getPendingTeachers() {
  try {
    const pendingQuery = query(collection(db, "users"), where("role", "==", "pending_teacher"))
    const snapshot = await getDocs(pendingQuery)

    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }))
  } catch (error) {
    console.error("Error getting pending teachers:", error)
    throw error
  }
}

export async function approveTeacher(teacherId) {
  try {
    await updateDoc(doc(db, "users", teacherId), {
      role: "teacher",
      approvedAt: new Date(),
    })
  } catch (error) {
    console.error("Error approving teacher:", error)
    throw error
  }
}

export async function rejectTeacher(teacherId) {
  try {
    await deleteDoc(doc(db, "users", teacherId))
  } catch (error) {
    console.error("Error rejecting teacher:", error)
    throw error
  }
}

