"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Loader2 } from "lucide-react"
import { getTeacherClasses } from "@/lib/services/class-service"
import { getStudentsByClass } from "@/lib/services/student-service"
import { saveResults, getResults } from "@/lib/services/results-service"

export function ResultsManagement() {
  const [classes, setClasses] = useState([])
  const [selectedClass, setSelectedClass] = useState("")
  const [examType, setExamType] = useState("midterm")
  const [students, setStudents] = useState([])
  const [resultsData, setResultsData] = useState({})
  const [loading, setLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)

  useEffect(() => {
    fetchClasses()
  }, [])

  useEffect(() => {
    if (selectedClass && examType) {
      fetchStudents()
      fetchResults()
    }
  }, [selectedClass, examType])

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
      setLoading(true)
      const studentsData = await getStudentsByClass(selectedClass)
      setStudents(studentsData)
    } catch (error) {
      console.error("Error fetching students:", error)
    } finally {
      setLoading(false)
    }
  }

  const fetchResults = async () => {
    try {
      setLoading(true)
      const results = await getResults(selectedClass, examType)

      // Convert array to object with studentId as key
      const resultsObj = {}
      results.forEach((item) => {
        resultsObj[item.studentId] = item.score
      })

      setResultsData(resultsObj)
    } catch (error) {
      console.error("Error fetching results:", error)
    } finally {
      setLoading(false)
    }
  }

  const handleScoreChange = (studentId, score) => {
    setResultsData((prev) => ({
      ...prev,
      [studentId]: score,
    }))
  }

  const handleSaveResults = async () => {
    try {
      setIsSaving(true)

      // Convert results data object to array
      const resultsArray = Object.keys(resultsData).map((studentId) => ({
        studentId,
        score: resultsData[studentId],
        examType,
        classId: selectedClass,
      }))

      await saveResults(selectedClass, examType, resultsArray)
      alert("Results saved successfully!")
    } catch (error) {
      console.error("Error saving results:", error)
      alert("Failed to save results.")
    } finally {
      setIsSaving(false)
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Results Management</CardTitle>
        <CardDescription>Enter and manage student exam results</CardDescription>
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
              <label htmlFor="exam-type">Exam Type</label>
              <Select value={examType} onValueChange={setExamType}>
                <SelectTrigger className="w-[200px]">
                  <SelectValue placeholder="Select exam type" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="midterm">Midterm</SelectItem>
                  <SelectItem value="final">Final</SelectItem>
                  <SelectItem value="groupwork">Group Work</SelectItem>
                  <SelectItem value="participation">Participation</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          {loading ? (
            <div className="flex justify-center py-8">
              <Loader2 className="h-8 w-8 animate-spin" />
            </div>
          ) : (
            <>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Student ID</TableHead>
                    <TableHead>Name</TableHead>
                    <TableHead>Score</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {students.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={3} className="text-center">
                        No students found in this class
                      </TableCell>
                    </TableRow>
                  ) : (
                    students.map((student) => (
                      <TableRow key={student.id}>
                        <TableCell>{student.studentId}</TableCell>
                        <TableCell>{student.name}</TableCell>
                        <TableCell>
                          <Input
                            type="number"
                            min="0"
                            max="100"
                            value={resultsData[student.studentId] || ""}
                            onChange={(e) => handleScoreChange(student.studentId, e.target.value)}
                            className="w-[100px]"
                          />
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>

              {students.length > 0 && (
                <div className="flex justify-end">
                  <Button onClick={handleSaveResults} disabled={isSaving}>
                    {isSaving ? (
                      <>
                        <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                        Saving...
                      </>
                    ) : (
                      "Save Results"
                    )}
                  </Button>
                </div>
              )}
            </>
          )}
        </div>
      </CardContent>
    </Card>
  )
}

