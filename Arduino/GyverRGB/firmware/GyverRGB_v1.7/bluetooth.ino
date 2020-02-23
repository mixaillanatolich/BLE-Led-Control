#define BLE_VERSION 1

#if (USE_BT == 1)
#define PARSE_AMOUNT 8    // максимальное количество значений в массиве, который хотим получить
#define header '$'        // стартовый символ
#define divider ','       // разделительный символ
#define ending ';'        // завершающий символ
int intData[PARSE_AMOUNT];     // массив численных значений после парсинга
boolean recievedFlag;
String request = "1234567891011121314151617181920";
boolean getStarted;
byte index;
String string_convert = "";

byte byte_convert[15];
byte byte_index = 0;

void sendSettings() {
  request = "";
  
#if (BLE_VERSION == 1)
  request += (char)0x55;
  request += (char)presetNum;
  request += (char)modeNum;
#else
  request += String("GS ");
  request += String(presetNum + 1);
  request += String(" ");
  request += String(modeNum + 1);
  request += String(" "); // +1 т.к. счёт в тункабл начинает с 1
#endif

  for (byte i = 0; i < 5; i++) {
#if (BLE_VERSION == 1)
    byte b1 = (presetSettings[i]>>8);
    byte b2 = (presetSettings[i]);
    request += (char) b2;
    request += (char) b1;
#else
    request += String(presetSettings[i]);
    request += String(" ");
#endif

    /*
    int len = request.length();
    for (int i = 0; i < len; i++) {
      Serial.print(request.charAt(i),DEC);
      Serial.print(" ");
    }
    Serial.println(" ");
    */
  }

#if (BLE_VERSION == 1)
  request += (char)ONflag;
#else
  request += ONflag;
#endif
  
  btSerial.print(request);

  /*
  Serial.println("");
  Serial.println(request);
  int len2 = request.length();
  for (int i = 0; i < len2; i++) {
    Serial.print(request.charAt(i),DEC);
    Serial.print(" ");
  }
  */
}

void bluetoothTick() {
  parsing();               // функция парсинга
  if (recievedFlag) {     // если получены данные
    recievedFlag = false;

    /*
    for (byte i = 0; i < index; i++) {
      Serial.print(intData[i]);
      Serial.print(" ");
    } 
    Serial.println(" ");
    for (byte i = 0; i < index; i++) {
      Serial.print(intData[i],HEX);
      Serial.print(" ");
    } 
    Serial.println("===========");
    */
    
    switch (intData[0]) {
      case 0:   // запрос онлайна
        request = "OK ";
        request += String(batPerc);
        btSerial.print(request);
        break;
      case 1:   // запрос состояния (настройки, пресет)
        sendSettings();
        btnControl = false;
        break;
      case 2:   // применить настройки
        for (byte i = 0; i < 6; i++) {
          presetSettings[i] = intData[i + 1];
        }
        presetSettings[setAmount[modeNum] - 1] = intData[6]; // белый
        settingsChanged = true;

        if (intData[7] != 10) invSet = intData[7];
        else invSet = setAmount[modeNum] - 1; // ой костыли бл*ть
        navPos = 2;
        invFlag = true;
        drawSettings();
        changeFlag = true;
        btnControl = false;
        eeprFlag = true;
        eeprTimer = millis();
        break;
      case 3:   // смена пресета
        changePresetTo(intData[1]);
        sendSettings();
        btnControl = false;
        eeprFlag = true;
        eeprTimer = millis();
        break;
      case 4:   // смена режима
        modeNum = intData[1];
        changeMode();
        sendSettings();
        btnControl = false;
        eeprFlag = true;
        eeprTimer = millis();
        break;
      case 5:   // вкл/выкл
        if (intData[1]) LEDon();
        else LEDoff();
        btnControl = false;
        break;
    }
  }
}

void parsing() {
  if (btSerial.available() > 0) {
    char incomingByte = btSerial.read();      // обязательно ЧИТАЕМ входящий символ

    /*
    Serial.print("b: ");
    Serial.print(incomingByte,HEX);
    Serial.print(" - ");
    Serial.println(incomingByte);
    */
    
    if (getStarted) {                         // если приняли начальный символ (парсинг разрешён)
      if (incomingByte != divider && incomingByte != ending) {   // если это не пробел И не конец
        string_convert += incomingByte;       // складываем в строку
        byte_convert[byte_index] = incomingByte;
        byte_index++;
      } else {                                // если это пробел или ; конец пакета

#if (BLE_VERSION == 1)
        if (byte_index == 1) {
          intData[index] = byte_convert[0];
        } else if (byte_index == 2) {
          intData[index] = 0;
          intData[index] |= ((int)byte_convert[0]) << 8;
          intData[index] |= ((int)byte_convert[1]) ;
        }

        if (byte_index == 12) {
          intData[0] = byte_convert[0];
          intData[1] = byte_convert[1];
          intData[2] = 0;
          intData[2] |= ((int)byte_convert[2]) << 8;
          intData[2] |= ((int)byte_convert[3]);
          intData[3] = 0;
          intData[3] |= ((int)byte_convert[4]) << 8;
          intData[3] |= ((int)byte_convert[5]);
          intData[4] = 0;
          intData[4] |= ((int)byte_convert[6]) << 8;
          intData[4] |= ((int)byte_convert[7]);
          intData[5] = 0;
          intData[5] |= ((int)byte_convert[8]) << 8;
          intData[5] |= ((int)byte_convert[9]);
          
          intData[6] = byte_convert[10];
          intData[7] = byte_convert[11];
          index = 7;
        }
#else
        intData[index] = string_convert.toInt();  // преобразуем строку в int и кладём в массив
#endif

        string_convert = "";                  // очищаем строку
        index++;                              // переходим к парсингу следующего элемента массива
        byte_index = 0;
      }
    }
    if (incomingByte == header) {             // если это $
      getStarted = true;                      // поднимаем флаг, что можно парсить
      index = 0;                              // сбрасываем индекс
      string_convert = "";                    // очищаем строку
    }
    if (incomingByte == ending) {             // если таки приняли ; - конец парсинга
      getStarted = false;                     // сброс
      recievedFlag = true;                    // флаг на принятие
    }
  }
}
#else
void bluetoothTick() {}
#endif
