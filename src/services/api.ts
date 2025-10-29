import mysqlApi from './mysql-api.service'

export interface Student {
  matricule: string
  fullname: string
  birthday: string
  birthplace: string
  city: string
  civilStatus: string
  avatar: string
  active: number
  promotionId: number
  schoolFilieres?: {
    shortName: string
  }
  schoolOrientations?: {
    title: string
  }
  firstname?: string
  lastname?: string
  gender?: string
  commune?: string
  district?: string
  street?: string
}

export interface AcademicStructure {
  id: number
  title: string
  label: string
  level: number
  entityId: number
}

class ApiService {
  async getStudent(matricule: string): Promise<Student | null> {
    try {
      return await mysqlApi.getStudentFromAkhademie(matricule)
    } catch (error) {
      console.error('Error fetching student from Akhademie:', error)
      return null
    }
  }

  async getStructure(): Promise<AcademicStructure[]> {
    try {
      return await mysqlApi.getStructureFromAkhademie()
    } catch (error) {
      console.error('Error fetching structure from Akhademie:', error)
      return []
    }
  }
}

export default new ApiService()
