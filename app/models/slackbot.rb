class Slackbot
  require 'slack'

  def self.notification
    Slack.configure {|config| config.token = ENV['LEGACY_TOKEN'] }
    client = Slack.realtime

    Slack.chat_postMessage(text: '「秘書！」と呼んでください。呼ばれたらできることを説明いたします。', channel: '#random')

    client.on :message do |data|
      # 秘書を読んでコマンドを確認したい時
      if data['text'].include?('秘書！') && data['subtype'] != 'bot_message'
        Slack.chat_postMessage(text: '「ビンゴ！」と言ったら、家事当番を決めます', channel: '#random')
        Slack.chat_postMessage(text: '「占い！」と言ったら、今日の運勢を占います。', channel: '#random')
        Slack.chat_postMessage(text: '「買い物リスト！」と言ったら、不足している日用品をリストします。', channel: '#random')
        Slack.chat_postMessage(text: '「購入！購入したもののID番号.買った個数」と言えば、買い物リストを更新できます。', channel: '#random')
        Slack.chat_postMessage(text: '「不足！不足しているもの.欲しい個数」と言えば、買い物リストに入れることができます。', channel: '#random')
      # 家事当番を決めたい時
      elsif data['text'].include?('ビンゴ！') && data['subtype'] != 'bot_message'
        people = ['@ryoma', '@urara']
        case Time.now.wday
        when 1
          Slack.chat_postMessage(text: 'ダンボールの日です', channel: '#random')
        when 2
          Slack.chat_postMessage(text: '燃えるゴミの日です', channel: '#random')
        when 3
          Slack.chat_postMessage(text: '燃えないゴミの日です', channel: '#random')
        when 6
          Slack.chat_postMessage(text: '燃えるゴミの日です', channel: '#random')
        end
        Slack.chat_postMessage(text: "じゃじゃ〜ん。ゴミ当番は#{people[rand(2)]}です", channel: '#random', link_names: true, mrkdwn: true)
        Slack.chat_postMessage(text: "じゃじゃ〜ん。朝ごはん当番は#{people[rand(2)]}です", channel: '#random', link_names: true, mrkdwn: true)
        Slack.chat_postMessage(text: "じゃじゃ〜ん。朝ごはん片付けは#{people[rand(2)]}です", channel: '#random', link_names: true, mrkdwn: true)
        Slack.chat_postMessage(text: "じゃじゃ〜ん。掃除当番は#{people[rand(2)]}です", channel: '#random', link_names: true, mrkdwn: true)
      # 占いをしたい時
      elsif data['text'].include?('占い！') && data['subtype'] != 'bot_message'
        fortune = ['大吉', '中吉', '小吉', '吉']
        Slack.chat_postMessage(text: "今日のあなたの運勢はーーーー？。#{fortune[rand(4)]}です!", channel: '#random')
      # 不足している日用品を知りたい時
      elsif data['text'].include?('買い物リスト！') && data['subtype'] != 'bot_message'
        if Item.all.exists?
          Slack.chat_postMessage(text: '不足している日用品はこちらです', channel: '#random')
          Item.all.each do |item|
            Slack.chat_postMessage(text: "ID番号#{item.id}:#{item.name}が#{item.number}個不足しています", channel: '#random')
          end
          Slack.chat_postMessage(text: '不足している日用品を買ったら「購入！番号.買った個数」と教えてください！', channel: '#random')
        else
          Slack.chat_postMessage(text: '不足している日用品はありません', channel: '#random')
        end
      # 不足している日用品を買った時
      elsif data['text'].include?('購入！') && data['subtype'] != 'bot_message'
        item_id     = data['text'].match(/！(\d+)/)[0].delete('！')
        item_number = data['text'].match(/\.(\d+)/)[0].delete('.').to_i
        item        = Item.find(item_id)
        item.update(number: item.number - item_number)
        item.destroy if item.number == 0
        Slack.chat_postMessage(text: "日用品ID:#{item_id}番を#{item_number}個買ってくれたんですねありがとうございます。", channel: '#random')
      # 不足している日用品をリストに追加したい時
      elsif data['text'].include?('不足！') && data['subtype'] != 'bot_message'
        item_name   = data['text'].match(/！.*\./)[0].delete('！').delete('.')
        item_number = data['text'].match(/\.(\d+)/)[0].delete('.')
        Item.create(name: item_name, number: item_number)
        Slack.chat_postMessage(text: "不足している日用品リストに#{item_name}を#{item_number}個追加しました！", channel: '#random')
      end
    end
    client.start
  end

end
