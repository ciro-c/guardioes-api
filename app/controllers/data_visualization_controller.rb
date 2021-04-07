require 'jwt'

class DataVisualizationController < ApplicationController
before_action :set_current_request_user, only: [:metabase_urls]

  def users_count
    return render json: User.count
  end

  def surveys_count
    return render json: Survey.count
  end

  def asymptomatic_surveys_count
    return render json: Survey.where(symptom:[]).count
  end

  def symptomatic_surveys_count
    return render json: Survey.where.not(symptom:[]).count
  end

  def metabase_urls
    case @current_request_user
    when current_admin
      payloadSurveys = {'params' => {'app' => @current_request_user.app_id}, 'resource' => {'dashboard' => 1}}
      payloadUsers = {'params' => {'app' => @current_request_user.app_id}, 'resource' => {'dashboard' => 1}}
      payloadBiosecurity = {'params' => {'app' => @current_request_user.app_id}, 'resource' => {'dashboard' => 1}}
    when current_manager
      payloadSurveys = {'params' => {'app' => @current_request_user.app_id}, 'resource' => {'dashboard' => 1}}
      payloadUsers = {'params' => {'app' => @current_request_user.app_id}, 'resource' => {'dashboard' => 1}}
      payloadBiosecurity = {'params' => {'app' => @current_request_user.app_id}, 'resource' => {'dashboard' => 1}}
    when current_city_manager
      payloadSurveys = {'params' => {'city' => @current_request_user.city}, 'resource' => {'dashboard' => 6}}
      payloadUsers = {'params' => {'city' => @current_request_user.city}, 'resource' => {'dashboard' => 6}}
      payloadBiosecurity = {'params' => {'city' => @current_request_user.city}, 'resource' => {'dashboard' => 6}}
    when current_group_manager
      payloadSurveys = {'params' => {'group' => @current_request_user.id}, 'resource' => {'dashboard' => 5}}
      payloadUsers = {'params' => {'group' => @current_request_user.id}, 'resource' => {'dashboard' => 5}}
      payloadBiosecurity = {'params' => {'group' => @current_request_user.id}, 'resource' => {'dashboard' => 5}}
    when current_user
      puts "Common user"
    end

    metabase_config = Rails.application.config.metabase
    req = JSON.parse(request.raw_post)

    iframe_urls = []
    exp_time = Time.now.to_i + metabase_config[:exp_time]

    payloadSurveys['exp'] = exp_time
    payloadUsers['exp'] = exp_time
    payloadBiosecurity['exp'] = exp_time

    tokenSurveys = JWT.encode payloadSurveys, metabase_config[:secret_key]
    tokenUsers = JWT.encode payloadUsers, metabase_config[:secret_key]
    tokenBiosecurity = JWT.encode payloadBiosecurity, metabase_config[:secret_key]

    iframe_urls.append({
      :dashboard => payloadSurveys['resource']['dashboard'],
      :iframe_url => "#{metabase_config[:site_url]}/embed/dashboard/#{tokenSurveys}#bordered=true&titled=true"
    })

    iframe_urls.append({
      :dashboard => payloadUsers['resource']['dashboard'],
      :iframe_url => "#{metabase_config[:site_url]}/embed/dashboard/#{tokenUsers}#bordered=true&titled=true"
    })

    iframe_urls.append({
      :dashboard => payloadBiosecurity['resource']['dashboard'],
      :iframe_url => "#{metabase_config[:site_url]}/embed/dashboard/#{tokenBiosecurity}#bordered=true&titled=true"
    })

    return render json: {
      'urls': iframe_urls
    }
  end

  private
    def set_current_request_user
      if not current_manager.nil?
        @current_request_user = current_manager
      elsif not current_group_manager.nil?
        @current_request_user = current_group_manager
      elsif not current_admin.nil?
        @current_request_user = current_admin
      elsif not current_city_manager.nil?
        @current_request_user = current_city_manager
      else
        return render json: { errors: "Token not found" }, status: :unprocessable_entity 
      end
    end 
end