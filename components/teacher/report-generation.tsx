"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Loader2, FileSpreadsheet } from "lucide-react"
import { getTeacherClasses } from "@/lib/services/class-service"
import { getClassAttendance } from "@/lib/services/attendance-service"
import { getClassResults } from "@/lib/services/results-service"
import { getStudentsByClass } from "@/lib/services/student-service"
import { generateExcelReport } from "@/lib/services/report-service"

export function ReportGeneration() {
  const [classes, setClasses] = useState([])
  const [selectedClass, setSelectedClass] = useState("")
  const [reportType, setReportType] = useState("attendance")
  const [loading, setLoading] = useState(true)
  const [isGenerating, setIsGenerating] = useState(false)
  const [previewData, setPreviewData] = useState([])
  const [students, setStudents] = useState([])

  useEffect(() => {
    fetchClasses()
  }, [])

  useEffect(() => {
    if (selectedClass) {
      fetchStudents()
      fetchPreviewData()
    }
  }, [selectedClass, reportType])

  const fetchClasses = async () => {
    try {
      setLoading(true)
      const classesData = await getTeacherClasses()
      setClasses(classesData)
      if (classesData.length > 0) {
        setSelectedClass(classesData[0].id)
      }
    } catch (error) {
      console.error("Error fetching classes:", error)
    } finally {
      setLoading(false)
    }
  }

  const fetchStudents = async () => {
    try {
      const studentsData = await getStudentsByClass(selectedClass)
      setStudents(studentsData)
    } catch (error) {
      console.error("Error fetching students:", error)
    }
  }

  const fetchPreviewData = async () => {
    try {
      setLoading(true)

      if (reportType === "attendance") {
        const attendanceData = await getClassAttendance(selectedClass)
        setPreviewData(attendanceData)
      } else if (reportType === "results") {
        const resultsData = await getClassResults(selectedClass)
        setPreviewData(resultsData)
      }
    } catch (error) {
      console.error("Error fetching preview data:", error)
    } finally {
      setLoading(false)
    }
  }

  const handleGenerateReport = async () => {
    try {
      setIsGenerating(true)

      // Get the selected class name
      const selectedClassObj = classes.find((cls) => cls.id === selectedClass)
      const className = selectedClassObj ? selectedClassObj.name : "Class"

      // Generate the report
      await generateExcelReport(selectedClass, reportType, className, students, previewData)

      alert("Report generated successfully!")
    } catch (error) {
      console.error("Error generating report:", error)
      alert("Failed to generate report.")
    } finally {
      setIsGenerating(false)
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Report Generation</CardTitle>
        <CardDescription>Generate Excel reports for attendance and results</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="grid gap-6">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
            <div className="grid gap-2">
              <label htmlFor="class-select">Select Class</label>
              <Select value={selectedClass} onValueChange={setSelectedClass}>
                <SelectTrigger className="w-[200px]">
                  <SelectValue placeholder="Select a class" />
                </SelectTrigger>
                <SelectContent>
                  {classes.map((cls) => (
                    <SelectItem key={cls.id} value={cls.id}>
                      {cls.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="grid gap-2">
              <label htmlFor="report-type">Report Type</label>
              <Select value={reportType} onValueChange={setReportType}>
                <SelectTrigger className="w-[200px]">
                  <SelectValue placeholder="Select report type" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="attendance">Attendance Report</SelectItem>
                  <SelectItem value="results">Results Report</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <div className="flex justify-end">
            <Button
              onClick={handleGenerateReport}
              disabled={isGenerating || loading}
              className="flex items-center gap-2"
            >
              {isGenerating ? (
                <>
                  <Loader2 className="h-4 w-4 animate-spin" />
                  Generating...
                </>
              ) : (
                <>
                  <FileSpreadsheet className="h-4 w-4" />
                  Generate Excel Report
                </>
              )}
            </Button>
          </div>

          <Card>
            <CardHeader>
              <CardTitle className="text-sm">Report Preview</CardTitle>
            </CardHeader>
            <CardContent>
              {loading ? (
                <div className="flex justify-center py-8">
                  <Loader2 className="h-8 w-8 animate-spin" />
                </div>
              ) : (
                <div className="text-sm">
                  {reportType === "attendance" ? (
                    <p>
                      This report will include attendance records for {students.length} students in the selected class,
                      showing present, absent, and late statuses for each date.
                    </p>
                  ) : (
                    <p>
                      This report will include exam results for {students.length} students in the selected class,
                      showing scores for midterm, final, group work, and participation.
                    </p>
                  )}
                </div>
              )}
            </CardContent>
          </Card>
        </div>
      </CardContent>
    </Card>
  )
}

