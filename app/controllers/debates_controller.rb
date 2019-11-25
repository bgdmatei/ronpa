require 'pry'

class DebatesController < ApplicationController
  def show
    @debate = Debate.find(params[:id])
    authorize @debate
    if @debate.finished?
      render 'debates/results'
    else
      render 'debates/show'
    end
  end

  def create
    @topic = Topic.find(params[:topic_id])
    authorize @topic
    if current_user.arguments.where(topic_id: @topic.id).count >= 6 && !current_user.in_debate?
      @debate = Debate.new(topic: @topic)
      authorize @debate
      if @debate.save
        Participant.create(debate: @debate, role: "moderator", user: current_user)
        redirect_to debate_path(@debate)
      end
    else
      redirect_to topic_path(@topic)
    end
  end


  def next_phase
    @debate = Debate.find(params[:debate_id])
    @topic = @debate.topic
    authorize @debate
    @debate.update(phase: Debate.phases[@debate.phase] + 1)
    @debate.broadcast_advance(current_user)
    # if @debate.phase == "finished"
    #   redirect_to dashboard_path
    # else
    #   render "debates/show"
    # end
  end
end
