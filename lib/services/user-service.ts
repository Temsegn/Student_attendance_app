import { db } from "@/lib/firebase"
import { doc, getDoc, setDoc } from "firebase/firestore"

export async function getUserRole(userId: string): Promise<string | null> {
  try {
    const userDoc = await getDoc(doc(db, "users", userId))

    if (userDoc.exists()) {
      return userDoc.data().role
    }

    return null
  } catch (error) {
    console.error("Error getting user role:", error)
    throw error
  }
}

export async function setUserRole(userId: string, role: string): Promise<void> {
  try {
    await setDoc(doc(db, "users", userId), { role }, { merge: true })
  } catch (error) {
    console.error("Error setting user role:", error)
    throw error
  }
}

