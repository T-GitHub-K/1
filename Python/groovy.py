import winsound
import time

# モールス信号を辞書として定義
morse_code = {
    'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.',
    'F': '..-.', 'G': '--.', 'H': '....', 'I': '..', 'J': '.---',
    'K': '-.-', 'L': '.-..', 'M': '--', 'N': '-.', 'O': '---',
    'P': '.--.', 'Q': '--.-', 'R': '.-.', 'S': '...', 'T': '-',
    'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-', 'Y': '-.--',
    'Z': '--..', '1': '.----', '2': '..---', '3': '...--', '4': '....-',
    '5': '.....', '6': '-....', '7': '--...', '8': '---..', '9': '----.',
    '0': '-----', ' ': ' ', ',': '--..--', '.': '.-.-.-', '?': '..--..',
    '/': '-..-.', '-': '-....-', '(': '-.--.', ')': '-.--.-'
}

# メッセージを入力してもらい、モールス信号に変換する関数
def encode_message(message):
    encoded_message = ""
    for letter in message:
        if letter.upper() in morse_code:
            encoded_message += morse_code[letter.upper()] + " "
        else:
            encoded_message += " "
    return encoded_message

# ユーザーにメッセージを入力してもらい、モールス信号に変換する
message = input("Enter your message: ")
encoded_message = encode_message(message)

# モールス信号を音で再生する
for symbol in encoded_message:
    if symbol == " ":
        # スペースは0.5秒待つ
        time.sleep(0.5)
    elif symbol == ".":
        # ピッと鳴らす
        winsound.Beep(1000, 250)
    elif symbol == "-":
        # 長く鳴らす
        winsound.Beep(1000, 750)