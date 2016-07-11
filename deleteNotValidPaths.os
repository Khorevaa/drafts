#Использовать "../github/parserV8i"

Функция ПолучитьТипБД(Путь) Экспорт
	
	ВариантБД = "";
	Если (СтрНачинаетсяС(Путь,"\\")) Тогда
		ВариантБД = "File";
	ИначеЕсли (Сред(Путь, 2, 1) = ":") Тогда
		ВариантБД = "File";
	ИначеЕсли (СтрНачинаетсяС(Путь,"http://")) Тогда
		ВариантБД = "ws";
	ИначеЕсли (СтрНачинаетсяС(Путь,"https://")) Тогда
		ВариантБД = "ws";
	Иначе
		ВариантБД = "Srvr";
	КонецЕсли;
	Возврат ВариантБД;

КонецФункции // ОпределитьТипБД(Парамеры) Экспорт

Процедура Выполнить()
	
	Парсер = Новый ПарсерСпискаБаз;
	Список = Парсер.ПолучитьСписокБаз();
	СписокБаз = Парсер.ПолучитьСписокБаз();
	

	Для каждого Стр Из Список Цикл
		База = Стр.Значение;
		Если База.Свойство("Connect") Тогда
			Если База.Connect.Structure.Свойство("File") Тогда
			ПутьКБазе = База.Connect.Structure.File;
			Если Лев(ПутьКБазе,1) = """" Тогда
				ПутьКБазе = Сред(ПутьКБазе,2);
			КонецЕсли;

			Если Прав(ПутьКБазе,1) = """" Тогда
				ПутьКБазе = Сред(ПутьКБазе,1,СтрДлина(ПутьКБазе)-1);
			КонецЕсли;
			Если ПолучитьТипБД(ПутьКБазе) = "File" Тогда
				Каталог = Новый Файл(ПутьКБазе);
				Если НЕ Каталог.Существует() Тогда
					СписокБаз.Удалить(Стр.Ключ);
					Сообщить("Удален путь к несуществующей базе: " + ПутьКБазе);
				КонецЕсли;
			КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	Парсер.ЗаписатьСписокБаз(СписокБаз);

КонецПроцедуры

Выполнить();