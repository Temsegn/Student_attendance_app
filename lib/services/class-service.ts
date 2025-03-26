import { db, auth } from "@/lib/firebase"
import { collection, doc, getDoc, getDocs, addDoc, updateDoc, deleteDoc, query, where } from "firebase/firestore"

export async function getTeacherClasses() {
  try {
    const user = auth.currentUser

    if (!user) {
      throw new Error("User not authenticated")
    }

    const classesQuery = query(collection(db, "classes"), where("teacherId", "==", user.uid))
    const snapshot = await getDocs(classesQuery)

    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }))
  } catch (error) {
    console.error("Error getting teacher classes:", error)
    throw error
  }
}

export async function createClass(classData) {
  try {
    const user = auth.currentUser

    if (!user) {
      throw new Error("User not authenticated")
    }

    const newClass = {
      ...classData,
      teacherId: user.uid,
      createdAt: new Date(),
    }

    const docRef = await addDoc(collection(db, "classes"), newClass)

    return {
      id: docRef.id,
      ...newClass,
    }
  } catch (error) {
    console.error("Error creating class:", error)
    throw error
  }
}

export async function updateClass(classId, classData) {
  try {
    await updateDoc(doc(db, "classes", classId), {
      ...classData,
      updatedAt: new Date(),
    })
  } catch (error) {
    console.error("Error updating class:", error)
    throw error
  }
}

export async function deleteClass(classId) {
  try {
    await deleteDoc(doc(db, "classes", classId))
  } catch (error) {
    console.error("Error deleting class:", error)
    throw error
  }
}

export async function enrollStudent(classId, studentId) {
  try {
    // Get current class data
    const classDoc = await getDoc(doc(db, "classes", classId))

    if (!classDoc.exists()) {
      throw new Error("Class not found")
    }

    const classData = classDoc.data()
    const students = classData.students || []

    // Add student if not already enrolled
    if (!students.includes(studentId)) {
      students.push(studentId)

      await updateDoc(doc(db, "classes", classId), {
        students,
        updatedAt: new Date(),
      })

      // Update student's classId
      await updateDoc(doc(db, "users", studentId), {
        classId,
        updatedAt: new Date(),
      })
    }
  } catch (error) {
    console.error("Error enrolling student:", error)
    throw error
  }
}

export async function removeStudent(classId, studentId) {
  try {
    // Get current class data
    const classDoc = await getDoc(doc(db, "classes", classId))

    if (!classDoc.exists()) {
      throw new Error("Class not found")
    }

    const classData = classDoc.data()
    const students = classData.students || []

    // Remove student if enrolled
    const updatedStudents = students.filter((id) => id !== studentId)

    await updateDoc(doc(db, "classes", classId), {
      students: updatedStudents,
      updatedAt: new Date(),
    })

    // Remove classId from student
    await updateDoc(doc(db, "users", studentId), {
      classId: null,
      updatedAt: new Date(),
    })
  } catch (error) {
    console.error("Error removing student:", error)
    throw error
  }
}

