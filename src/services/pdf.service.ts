import jsPDF from 'jspdf'
import autoTable from 'jspdf-autotable'
import type { AttendanceRecord } from './attendance.service'

interface PDFExportOptions {
  teacherName: string
  courseName?: string
  date: string
  records: AttendanceRecord[]
}

class PDFService {
  generateAttendancePDF(options: PDFExportOptions): void {
    const doc = new jsPDF()
    const pageWidth = doc.internal.pageSize.getWidth()

    doc.setFontSize(16)
    doc.setFont('helvetica', 'bold')
    doc.text('Université Catholique de Bukavu', pageWidth / 2, 20, { align: 'center' })

    doc.setFontSize(14)
    doc.text('Feuille de Présence', pageWidth / 2, 30, { align: 'center' })

    doc.setFontSize(10)
    doc.setFont('helvetica', 'normal')
    doc.text(`Date: ${this.formatDate(options.date)}`, 14, 45)
    doc.text(`Professeur: ${options.teacherName}`, 14, 52)

    if (options.courseName) {
      doc.text(`Cours: ${options.courseName}`, 14, 59)
    }

    const tableData = options.records.map((record, index) => [
      (index + 1).toString(),
      record.student_matricule || '',
      record.student_name || '',
      this.formatDateTime(record.date_heure),
      ''
    ])

    autoTable(doc, {
      startY: options.courseName ? 65 : 60,
      head: [['N°', 'Matricule', 'Nom Complet', 'Heure d\'arrivée', 'Signature']],
      body: tableData,
      theme: 'grid',
      styles: {
        fontSize: 9,
        cellPadding: 4
      },
      headStyles: {
        fillColor: [0, 51, 102],
        textColor: 255,
        fontStyle: 'bold'
      },
      columnStyles: {
        0: { cellWidth: 15 },
        1: { cellWidth: 35 },
        2: { cellWidth: 50 },
        3: { cellWidth: 40 },
        4: { cellWidth: 40 }
      }
    })

    const finalY = (doc as any).lastAutoTable.finalY || 100

    doc.setFontSize(9)
    doc.text(`Total des présences: ${options.records.length}`, 14, finalY + 10)

    doc.text('Signature du professeur:', 14, finalY + 25)
    doc.text('_________________________', 14, finalY + 35)

    doc.setFontSize(8)
    doc.setTextColor(128, 128, 128)
    doc.text(`Document généré le ${this.formatDateTime(new Date().toISOString())}`, 14, doc.internal.pageSize.getHeight() - 10)

    const filename = `Presences_${options.courseName?.replace(/\s+/g, '_') || 'cours'}_${options.date}.pdf`
    doc.save(filename)
  }

  private formatDate(dateString: string): string {
    const date = new Date(dateString)
    return date.toLocaleDateString('fr-FR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    })
  }

  private formatDateTime(dateString: string): string {
    const date = new Date(dateString)
    return date.toLocaleString('fr-FR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }
}

export default new PDFService()
