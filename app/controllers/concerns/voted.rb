module Voted
  extend ActiveSupport::Concern
  included do
    before_action :authenticate_user!, only: %i[upvote downvote cancel_vote]
    before_action :find_voted_resource, only: %i[upvote downvote cancel_vote]

    def upvote
      if @voted_resource.voteable_by?(current_user)
        @voted_resource.upvote(current_user)

        # Answer with updated info in json format
        # will be used by JS script on page to update
        # votes info
        render json: votes_json
      else
        return head :unprocessable_entity
      end
    end
    
    def downvote
      if @voted_resource.voteable_by?(current_user)
        @voted_resource.downvote(current_user)
        render json: votes_json
      else
        return head :unprocessable_entity
      end
    end

    def cancel_vote
      if @voted_resource.vote_by_user(current_user)
        @voted_resource.vote_by_user(current_user).destroy
        render json: votes_json
      else
        return head :unprocessable_entity
      end
    end
  end

  def find_voted_resource
    @voted_resource = controller_name.classify.constantize.find(params[:id])
  end

  def votes_json
    { id: @voted_resource.id, rating: @voted_resource.rating, resource_type: @voted_resource.class.name }
  end
end
