def extract_lines_with_character(text, character):
    lines = text.split('\n')  # テキストを行ごとに分割

    result = []
    for line in lines:
        if character in line:
            result.append(line)  # 指定した文字が含まれている行を結果に追加

    return result

text_data = '''
This is line 1.
Line 2 contains the character 'a'.
Line 3 does not contain the character.
Line 4 has multiple 'a's.
'''

character = '1'
result = extract_lines_with_character(text_data, character)
for line in result:
    print(line)
