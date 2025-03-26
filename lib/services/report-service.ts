import { storage } from "@/lib/firebase"
import { ref, uploadBytes, getDownloadURL } from "firebase/storage"
import * as XLSX from "xlsx"

export async function generateExcelReport(classId, reportType, className, students, data) {
  try {
    // Create workbook
    const wb = XLSX.utils.book_new()

    if (reportType === "attendance") {
      // Process attendance data
      const processedData = processAttendanceData(students, data)
      const ws = XLSX.utils.json_to_sheet(processedData)
      XLSX.utils.book_append_sheet(wb, ws, "Attendance")
    } else if (reportType === "results") {
      // Process results data
      const processedData = processResultsData(students, data)
      const ws = XLSX.utils.json_to_sheet(processedData)
      XLSX.utils.book_append_sheet(wb, ws, "Results")
    }

    // Convert to binary
    const excelBuffer = XLSX.write(wb, { bookType: "xlsx", type: "array" })
    const blob = new Blob([excelBuffer], { type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" })

    // Generate filename
    const timestamp = new Date().toISOString().replace(/[:.]/g, "-")
    const filename = `${className}_${reportType}_${timestamp}.xlsx`

    // Upload to Firebase Storage
    const storageRef = ref(storage, `reports/${filename}`)
    await uploadBytes(storageRef, blob)

    // Get download URL
    const downloadURL = await getDownloadURL(storageRef)

    // Trigger download in browser
    const a = document.createElement("a")
    a.href = downloadURL
    a.download = filename
    a.click()

    return downloadURL
  } catch (error) {
    console.error("Error generating Excel report:", error)
    throw error
  }
}

function processAttendanceData(students, attendanceData) {
  // Group attendance by date
  const attendanceByDate = {}

  attendanceData.forEach((record) => {
    if (!attendanceByDate[record.date]) {
      attendanceByDate[record.date] = {}
    }
    attendanceByDate[record.date][record.studentId] = record.status
  })

  // Create rows for each student
  return students.map((student) => {
    const row = {
      "Student ID": student.studentId,
      Name: student.name,
    }

    // Add a column for each date
    Object.keys(attendanceByDate)
      .sort()
      .forEach((date) => {
        row[date] = attendanceByDate[date][student.studentId] || "N/A"
      })

    return row
  })
}

function processResultsData(students, resultsData) {
  // Group results by exam type
  const resultsByType = {
    midterm: {},
    final: {},
    groupwork: {},
    participation: {},
  }

  resultsData.forEach((record) => {
    if (resultsByType[record.examType]) {
      resultsByType[record.examType][record.studentId] = record.score
    }
  })

  // Create rows for each student
  return students.map((student) => {
    return {
      "Student ID": student.studentId,
      Name: student.name,
      Midterm: resultsByType.midterm[student.studentId] || "N/A",
      Final: resultsByType.final[student.studentId] || "N/A",
      "Group Work": resultsByType.groupwork[student.studentId] || "N/A",
      Participation: resultsByType.participation[student.studentId] || "N/A",
      Total: calculateTotal(student.studentId, resultsByType),
    }
  })
}

function calculateTotal(studentId, resultsByType) {
  const midterm = Number.parseFloat(resultsByType.midterm[studentId]) || 0
  const final = Number.parseFloat(resultsByType.final[studentId]) || 0
  const groupwork = Number.parseFloat(resultsByType.groupwork[studentId]) || 0
  const participation = Number.parseFloat(resultsByType.participation[studentId]) || 0

  // Calculate weighted total (example weights)
  const total = midterm * 0.3 + final * 0.4 + groupwork * 0.2 + participation * 0.1

  return total.toFixed(2)
}

