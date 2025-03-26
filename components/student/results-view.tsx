"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Loader2 } from "lucide-react"
import { getStudentResults } from "@/lib/services/results-service"

export function ResultsView({ studentId }) {
  const [results, setResults] = useState([])
  const [loading, setLoading] = useState(true)
  const [overallGrade, setOverallGrade] = useState(null)

  useEffect(() => {
    if (studentId) {
      fetchResults()
    }
  }, [studentId])

  const fetchResults = async () => {
    try {
      setLoading(true)
      // Note: In a real app, we would get the classId from the student's data
      // For simplicity, we're passing null to get all results records
      const resultsData = await getStudentResults(studentId, null)

      setResults(resultsData)

      // Calculate overall grade
      calculateOverallGrade(resultsData)
    } catch (error) {
      console.error("Error fetching results:", error)
    } finally {
      setLoading(false)
    }
  }

  const calculateOverallGrade = (resultsData) => {
    // Group results by class
    const resultsByClass = {}

    resultsData.forEach((record) => {
      if (!resultsByClass[record.classId]) {
        resultsByClass[record.classId] = {
          midterm: null,
          final: null,
          groupwork: null,
          participation: null,
        }
      }

      resultsByClass[record.classId][record.examType] = Number.parseFloat(record.score)
    })

    // Calculate overall grade for each class
    const overallGrades = {}

    Object.keys(resultsByClass).forEach((classId) => {
      const classResults = resultsByClass[classId]

      // Apply weights (example weights)
      let total = 0
      let weightSum = 0

      if (classResults.midterm !== null) {
        total += classResults.midterm * 0.3
        weightSum += 0.3
      }

      if (classResults.final !== null) {
        total += classResults.final * 0.4
        weightSum += 0.4
      }

      if (classResults.groupwork !== null) {
        total += classResults.groupwork * 0.2
        weightSum += 0.2
      }

      if (classResults.participation !== null) {
        total += classResults.participation * 0.1
        weightSum += 0.1
      }

      // Calculate weighted average
      const weightedAverage = weightSum > 0 ? total / weightSum : 0

      overallGrades[classId] = {
        score: weightedAverage.toFixed(2),
        grade: getLetterGrade(weightedAverage),
      }
    })

    setOverallGrade(overallGrades)
  }

  const getLetterGrade = (score) => {
    if (score >= 90) return "A"
    if (score >= 80) return "B"
    if (score >= 70) return "C"
    if (score >= 60) return "D"
    return "F"
  }

  const getExamTypeLabel = (examType) => {
    switch (examType) {
      case "midterm":
        return "Midterm Exam"
      case "final":
        return "Final Exam"
      case "groupwork":
        return "Group Work"
      case "participation":
        return "Participation"
      default:
        return examType
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Exam Results</CardTitle>
        <CardDescription>View your exam and assessment results</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="grid gap-6">
          {overallGrade && Object.keys(overallGrade).length > 0 && (
            <div className="grid gap-4 sm:grid-cols-2">
              {Object.keys(overallGrade).map((classId) => (
                <Card key={classId}>
                  <CardContent className="p-4">
                    <div className="text-sm text-muted-foreground">Overall Grade</div>
                    <div className="flex items-end justify-between">
                      <div className="text-3xl font-bold">{overallGrade[classId].grade}</div>
                      <div className="text-xl">{overallGrade[classId].score}%</div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}

          {loading ? (
            <div className="flex justify-center py-8">
              <Loader2 className="h-8 w-8 animate-spin" />
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Class</TableHead>
                  <TableHead>Assessment</TableHead>
                  <TableHead>Score</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {results.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={3} className="text-center">
                      No results found
                    </TableCell>
                  </TableRow>
                ) : (
                  results.map((record, index) => (
                    <TableRow key={index}>
                      <TableCell>{record.className || "Class"}</TableCell>
                      <TableCell>{getExamTypeLabel(record.examType)}</TableCell>
                      <TableCell>{record.score}</TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          )}
        </div>
      </CardContent>
    </Card>
  )
}

