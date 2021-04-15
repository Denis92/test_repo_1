//
//  QuestionnaireResponse.swift
//  ForwardLeasing
//

import Foundation

struct QuestionnaireResponse: Decodable {
  enum CodingKeys: String, CodingKey {
    case questions = "gradeQuestions", gradeInfos = "gradeInfos"
  }
  
  let questions: [Question]
  let gradeInfos: [QuestionGradeInfo]
}
