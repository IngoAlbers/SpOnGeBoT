require 'telegram/bot'
require 'json'
require 'net/http'

class SpongeBot
  def initialize
    Telegram::Bot::Client.run(telegram_api_token) do |bot|
      bot.listen do |message|
        if message.is_a?(Telegram::Bot::Types::InlineQuery) && message.query.length > 5
          @text = message.query
          bot.api.answer_inline_query(inline_query_id: message.id, results: results)
        end
      end
    end
  end

  private

  def results
    [Telegram::Bot::Types::InlineQueryResultArticle.new(
      id: 1,
      title: @text,
      input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(message_text: image_url)
    )]
  end

  def telegram_api_token
    ENV['TELEGRAM_API_TOKEN']
  end

  def image_text
    @text.gsub!(/\w/).with_index { |s, i| i.even? ? s.upcase : s.downcase }
  end

  def image_url
    JSON.parse(meme_request.body)['data']['url']
  end

  def meme_request
    Net::HTTP.post_form(URI.parse('https://api.imgflip.com/caption_image'),
                        template_id: 102_156_234,
                        text0: '',
                        text1: '',
                        'boxes[0][text]' => '',
                        'boxes[1][text]' => image_text,
                        username: 'imgflip_hubot',
                        password: 'imgflip_hubot')
  end
end

SpongeBot.new
