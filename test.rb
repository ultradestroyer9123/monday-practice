require 'pry'
require "byebug"
require "./lib/monday_ruby"
require 'dotenv/load'

client = Monday::Client.new(
  token: ENV['MONDAY_DEV_KEY'],
  version: '2024-10'
)

# -- Workspaces -------------------
response = client.workspace.query(select: %w[id name])
workspaces = response.body['data']['workspaces']
# [{"id"=>"4064708", "name"=>"My Team"}, {"id"=>"3067385", "name"=>"WorkForms"}, {"id"=>"2874595", "name"=>"No Longer Using"}]


byebug
asdf=3

# -- Boards -------------------
# args = {
#   state: :active
# }
# response = client.board.query(args: args, select: %w[id name state])
# boards = response.body['data']['boards']


# byebug
# asdf=3

# state: active

## -- Board Search -------------------

# def item_page_with_integration_id_str(cursor)
#   cursor_str = cursor.present? ? ", cursor: \"#{cursor}\"" : ''
#   <<-GRAPHQL.squish
#     items_page(limit: 100 #{cursor_str}) {
#       cursor
#       items {
#         id
#         name
#         group { title }
#         column_values(ids: [#{@monday_column_map.join(',')}]) {
#           column { title }
#           id type text value
#           ... on BoardRelationValue {
#             linked_item_ids
#           }
#         }
#       }
#     }
#   GRAPHQL
# end


@monday_column_map = [
  "\"name\"",
  "\"text\"",
  "\"status5\"",
  "\"date\"",
  "\"date5\"",
  "\"status8\"",
  "\"status1\"",
  "\"text3\"",
  "\"status2\"",
  "\"numbers5\"",
  "\"numbers9\"",
  "\"numeric_mknpm382\"",
  "\"numeric_mknpsnn2\"",
  "\"numeric_mknp5s8k\"",
  "\"numeric_mknpmt2f\"",
  "\"numeric_mknpe5yh\"",
  "\"numeric_mknpj416\"",
  "\"date_mknpxkr9\"",
  "\"date_mknpc1vf\"",
  "\"link_mknpqdy2\"",
  "\"text_mknsnc07\"",
  "\"text_mknseyf7\"",
  "\"text0\"",
  "\"text2\"",
  "\"text1\"",
  "\"text76\"",
  "\"text86\"",
  "\"email\"",
  "\"phone\"",
  "\"dup__of_tenant1id\"",
  "\"text53\"",
  "\"text6\"",
  "\"text9\"",
  "\"email6\"",
  "\"phone7\"",
  "\"dup__of_tenant2id\"",
  "\"text67\"",
  "\"text8\"",
  "\"text19\"",
  "\"email62\"",
  "\"phone9\"",
  "\"text03\"",
  "\"text66\"",
  "\"text4\"",
  "\"text92\"",
  "\"email9\"",
  "\"phone8\"",
  "\"text_mknph4ha\"",
  "\"text26\"",
  "\"text_mknp3fck\""
]

args = {
  ids: 6864633230
}
request_query = <<-GRAPHQL
  items_page (limit: 1, query_params: {rules: [{column_id: "text", compare_value: "2349210"}]}) {
    items {
      id
      name
      group { title }
      column_values(ids: [#{@monday_column_map.join(',')}]) {
        column { title }
        id type text value
        ... on BoardRelationValue {
          linked_item_ids
        }
      }
    }
  }
GRAPHQL
response = client.board.query(args: args, select: ['id', 'name', request_query])
boards = response.body['data']['boards']

binding.pry
asdf=3




# -- List Board Columns -------------------
# board_id = 7621025320 # Tenant Balances
# args = {
#   ids: board_id
# }
# response = client.board.query(args: args, select: ['id', 'name', 'columns { id title type settings_str }'])
# data = response.body['data']
# board_columns = response.body['data']['boards'].first['columns']



# -- List Board Items -------------------
# buildium_ids = []

# board_id = 7086565144
# args = {
#   ids: board_id
# }
# item_page_str = 'items_page(limit: 2) { items { id name column_values(ids: ["text2"]) { column { id title } id text type value } } }'
# response = client.board.query(args: args, select: ['id', 'name', item_page_str])
# data = response.body['data']['boards'].first['items_page']['items']

# properties += data['boards'].first['items_page']['items']

# cursor = data['boards'].first['items_page']['cursor']
# response = client.board.query(args: args, select: ['id', 'name', "items_page (limit: 2, cursor: \"#{cursor}\") { cursor items { id name }}"])
# data = response.body['data']
# properties += data['boards'].first['items_page']['items']


# -- Update Board Items -------------------
# properties_board_id = 3971778798
# property_item_id = 4165011695
# args = {
#   board_id: properties_board_id,
#   item_id: property_item_id,
#   column_id: "numbers5",
#   value:"3032"
# }
# response = client.column.change_value(args: args, select: ['id', 'name'])
# data = response.body['data']


# -- Update Multiple Board Items -------------------
# board_id = 8386556594
# item_id = 8402386195
# args = {
#   board_id: board_id,
#   item_id: item_id,
#   column_values: {
#     "color_mksbgrq7": {"label": "Test 2"}
#   },
#   create_labels_if_missing: :true
# }

# byebug
# asdf=3

# response = client.column.change_multiple_values(args: args, select: ['id', 'name'])

# byebug
# asdf=3

# data = response.body['data']

########################################################
# Create workspace: LaunchEngine
########################################################

# args = {
#   name: 'LaunchEngine Test Workspace',
#   kind: :open,
#   description: 'LaunchEngine workspace for testing'
# }
# workspace = client.workspace.create(args: args)
# workspace_id = workspace.body['data']['create_workspace']['id']
# puts "Workspace ID: #{workspace_id}"

# args = {
#   name: 'Database',
#   workspace_id: workspace_id
# }
# folder = client.folder.create(args: args)
# folder_id = folder.body['data']['create_folder']['id']
# puts "Folder ID: #{folder_id}"


# byebug
# asdf=3

# args = {
#   workspace_ids: workspace_id
# }
# folders = client.folder.query(args: args)
# folder_list = folders.body['data']['folders']
# folder_list.each do |folder|
#   puts "Folder ID: #{folder['id']}, Name: #{folder['name']}"
# end

# byebug
# asdf=3


# args = {
#   folder_id: folder_id,
#   name: 'Dogs'
# }
# client.folder.update(args: args)


# byebug
# asdf=3

# args = {
#   folder_id: 15476573,
# }
# client.folder.delete(args: args)

# args = {
#   name: 'Vendors',
#   folder_id: folder_id,
#   board_kind: :public,
#   description: 'Vendors board'
# }
# vendors_board = client.board.create(args: args)

# byebug
# asdf = 3


########################################################
# OLD NOTES BELOW
########################################################


# # -- Boards -------------------
# workspace_id = 2_717_276
# args = {
#   workspace_ids: [workspace_id]
# }
# response = client.boards
# boards = response.body
# response = client.boards(args: args)
# boards = response.body['data']['boards'].map { |board| [board['id'], board['name']].join('::') }.sort
# board_id = 4_408_896_541


# workspace_id = 2_717_276
# args = {
#   workspace_id: workspace_id,
#   board_name: 'Bestimate',
#   board_kind: 'public',
#   description: 'Bestimate board'
# }
# response = client.create_board(args: args)
# board = response.body['data']['create_board']

# # -- Groups -------------------
# # args = {
# #   ids: board_id
# # }
# # response = client.groups(args: args)
# # # groups = response.body
# # groups = response.body['data']['boards'].first['groups'].map { |group| group['title'] }.sort
# # # group_id = 'returned_orders66125'

# # args = {
# #   board_id: board_id,
# #   group_name: 'TEST GROUP'
# # }
# # response = client.create_group(args: args)

# # args = {
# #   board_id: board_id,
# #   group_id: 'returned_orders66125',
# #   group_attribute: 'title',
# #   new_value: 'Voided orders'
# # }
# # response = client.update_group(args: args)

# # args = {
# #   board_id: board_id,
# #   group_id: 'returned_orders66125'
# # }
# # response = client.delete_group(args: args)

# # args = {
# #   board_id: board_id,
# #   group_id: 'returned_orders66125',
# #   add_to_top: true
# # }
# # response = client.duplicate_group(args: args)

# # args = {
# #   board_id: board_id,
# #   group_id: 'duplicate_of_returned_orders'
# # }
# # response = client.archive_group(args: args)

# args = {
#   ids: board_id
# }
# response = client.groups(args: args, select: ["id", "title", "items { id, name }"])
# # groups = response.body
# groups = response.body["data"]["boards"].first["groups"].map { |group| group["title"] }.sort

# # args = {
# #   item_id: '5204596062',
# #   group_id: 'returned_orders66125'
# # }
# # response = client.move_item_to_group(args: args)

# -- Subitems -------------------

# workspace_id = 2717276
# args = {
#   workspace_ids: [workspace_id]
# }
# response = client.boards(args: args)
# boards = response.body['data']['boards'].map { |board| [board['id'],board['name']].join('::') }

# board_id = 5413662927
# args = {
#   ids: [board_id]
# }
# response = client.boards(args: args, select: %w[id name description items { id name }])
# items = response.body['data']['boards'].first['items']

# item_id = 5413662935
# args = {
#   ids: [item_id]
# }
# # response = client.subitems(args: args, select: ['id', 'name', 'column_values {id value text}'])
# response = client.subitems(args: args, select: ['id', 'name'])
# subitems = response.body['data']['items'].first['subitems']

# [{"id"=>"5236092350", "name"=>"1001-A", "column_values"=>[{"id"=>"person", "value"=>"{\"changed_at\":\"2023-09-27T20:58:10.495Z\",\"personsAndTeams\":[{\"id\":42835270,\"kind\":\"person\"}]}", "text"=>"Wes Hays"}, {"id"=>"status", "value"=>"{\"index\":0,\"post_id\":null,\"changed_at\":\"2023-09-27T20:06:21.627Z\"}", "text"=>"Working on it"}, {"id"=>"date0", "value"=>"{\"date\":\"2023-09-27\",\"changed_at\":\"2023-09-27T20:06:27.204Z\"}", "text"=>"2023-09-27"}]}]

# item_id = 5413662935
# args = {
#   parent_item_id: item_id,
#   item_name: "New item 5",
#   # column_values: {
#   #   person: { personsAndTeams: [{ id: 42_835_270, kind: "person" }] },
#   #   status: "Done",
#   #   date0: "2021-09-15"
#   # }
# }
# subitem = client.create_subitem(args: args)

# -- Updates -------------------

# args = {
#   limit: 1_000
# }
# updates = client.updates(args: args)


# item_id = '5204603920'
# args = {
#   ids: [item_id],
# }
# item = client.items(args: args, select: ["id", "name", "updates { id body created_at }"])


# item_id = '5204603920'
# args = {
#   item_id: item_id,
#   body: "This update will be added to the item"
# }
# update = client.create_update(args: args)

# update_id = '2464664939'
# args = {
#   update_id: update_id
# }
# update = client.like_update(args: args)


# item_id = '5204603920'
# args = {
#   item_id: item_id,
#   body: "This update will be added to the item"
# }
# update = client.create_update(args: args)

# item_id = '5204603920'
# args = {
#   item_id: item_id
# }
# update = client.clear_item_updates(args: args)


# item_id = '5204603920'
# args = {
#   item_id: item_id,
#   body: "This update will be added to the item"
# }
# update = client.create_update(args: args)

# update_id = update.body['data']['create_update']['id']
# args = {
#   id: update_id
# }
# update = client.delete_update(args: args)


# -- Files -------------------

# item_id = '5204603920'
# args = {
#   ids: item_id
# }
# files = client.files(args: args)

# item_id = '5204603920'
# args = {
#   item_id: item_id,
#   body: "This update will be added to the item"
# }
# update = client.create_update(args: args)

# item_id = '4946752932'
# update_id = '2500806905' # Bad?
# update_id = '2478047808' # From Bill
# args = {
#   update_id: update_id,
#   '$file' => File.expand_path('./spec/test_files/polarBear.jpg')
# }
# files = client.add_file_to_update(args: args)

# -- Columns -------------------
