class JobSerializer < ActiveModel::Serializer
  attributes :id,
    :build_id,
    :created_at,
    :status,
    :build_commit_message

  def build_commit_message
    object.build.commit_message
  end
end
