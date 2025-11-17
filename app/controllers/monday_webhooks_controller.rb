class MondayWebhooksController < ApplicationController
  before_action :check_for_monday_challenge

  def student_update
    # MissionControlUpdateJob.perform_later(params[:event][:pulseId])
    event = params[:event]
    boardId = event[:boardId]
    pulseId = event[:pulseId]
    if boardId == 18380266024
      GenerateStudentPandadoc.process(pulseId)
    end
    head :ok
  end

  private

  def check_for_monday_challenge
    return if params[:challenge].blank?

    render json: { challenge: params[:challenge]}
  end
end
