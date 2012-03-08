require 'net/http'
require 'uri'

class AuthProvider
  
  def self.get_edmodo_id(user_token)
    url = URI.parse(STUDYEGG_USER_MANAGER_PATH + "/api/get_edmodo_id/" + user_token)
    req = Net::HTTP.post_form(url, {"user_token" => user_token})
    begin
      edmodo_id = JSON.parse(req.body)
    rescue
      edmodo_id = []
    end
    return edmodo_id 
  end

  def self.get_all_devise_users
    uri = URI.parse(URI.encode(STUDYEGG_USER_MANAGER_PATH+"/api/export_all_users"))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = false
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    res = http.request(request)
    begin
      response = JSON.parse(res.body)
    rescue
      response=[]
    end
    
    return response
  end

  def self.get_groups_by_user_id(user_id)
    url = URI.parse(STUDYEGG_USER_MANAGER_PATH + "/api/get_groups_by_user_id")
    req = Net::HTTP.post_form(url, {"user_id" => user_id})
    begin
      groups = JSON.parse(req.body)
    rescue
      groups = []
    end
    return groups 
  end

  def self.get_students_by_teacher_id(teacher_id)
    url = URI.parse(STUDYEGG_USER_MANAGER_PATH + "/api/get_students_by_teacher_id/#{teacher_id}")
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    begin
      students = JSON.parse(res.body)
    rescue
      students = []
    end
    return students
  end

  def self.get_students_by_teacher_email(email)
    url = URI.parse(STUDYEGG_USER_MANAGER_PATH + "/api/get_students_by_teacher_email")
    req = Net::HTTP.post_form(url, {"email" => email})
    begin
      students = JSON.parse(req.body)
    rescue
      students = []
    end
    return students
  end 

  def self.get_students_by_group_id(group_id)
    url = URI.parse(STUDYEGG_USER_MANAGER_PATH + "/api/get_students_by_group_id")
    req = Net::HTTP.post_form(url, {"group_id" => group_id})
    begin
      students = JSON.parse(req.body)
    rescue
      students = []
    end
    return students
  end  
  
  def self.get_class_student_count(group_id)
    url = URI.parse(STUDYEGG_USER_MANAGER_PATH + "/api/get_class_student_count/#{group_id}")
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }    
    begin
      question_count = res.body
    rescue
      question_count = nil
    end
    return question_count 
  end
   
end