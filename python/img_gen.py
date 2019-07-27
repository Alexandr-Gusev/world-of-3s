from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains
from PIL import Image
from io import BytesIO
import time

driver = None

def save_1(fn, w, h):
	png = driver.get_screenshot_as_png()

	im = Image.open(BytesIO(png))
	im = im.crop((0, 0, w, h))
	im.save(fn)

def save_32(w, h, key):
	res = Image.new('RGB', (w, h), color='red')
	w = int(h / 4)

	i = 0
	while i < 32:
		png = driver.get_screenshot_as_png()

		im = Image.open(BytesIO(png))
		im = im.crop((0, 0, w, w))
		x = (i % 8) * w
		y = int(i / 8) * w
		res.paste(im, (x, y, x + w, y + w))

		ActionChains(driver).send_keys(key).perform()
		time.sleep(1)

		i = i + 1

	res.save('res.png')

try:
	driver = webdriver.Chrome()

except Exception as ex:
	print (ex)
	exit()

url = 'http://127.0.0.1/world-of-3s/WebGL/'

def px(preset, w, h):
	driver.get('%s?preset=%s' % (url, preset))
	time.sleep(1)
	save_1('res.png', w, h)

def save_4(preset, w):
	res = Image.new('RGB', (w * 2, w * 2), color='red')

	i = 0
	while i < 4:
		driver.get('%s?preset=%s' % (url, preset + i))
		time.sleep(1)
		png = driver.get_screenshot_as_png()

		im = Image.open(BytesIO(png))
		im = im.crop((0, 0, w, w))
		x = (i % 2) * w
		y = int(i / 2) * w
		res.paste(im, (x, y, x + w, y + w))

		i = i + 1

	res.save('res.png')

def save_2(presets, w, d):
	res = Image.new('RGB', (w * 2 - d * 2, w), color='red')

	driver.get('%s?preset=%s' % (url, presets[0]))
	time.sleep(1)
	png = driver.get_screenshot_as_png()

	im = Image.open(BytesIO(png))
	im = im.crop((0, 0, w - d, w))
	res.paste(im, (0, 0))

	driver.get('%s?preset=%s' % (url, presets[1]))
	time.sleep(1)
	png = driver.get_screenshot_as_png()

	im = Image.open(BytesIO(png))
	im = im.crop((d, 0, w, w))
	res.paste(im, (w - d, 0))

	res.save('res.png')

def p1020():
	driver.get('%s?preset=1020' % url)
	time.sleep(1)
	save_32(1200, 600, 'S')

def p1030():
	driver.get('%s?preset=1030' % url)
	time.sleep(1)
	save_32(1200, 600, Keys.ARROW_UP)

def p1050():
	driver.get('%s?preset=1050' % url)
	time.sleep(1)
	i = 0
	while i < 266:
		save_1('res/%03d.png' % i, 640, 360)
		ActionChains(driver).key_down(Keys.ALT).send_keys(Keys.ARROW_DOWN).key_up(Keys.ALT).perform()
		time.sleep(1)
		i = i + 1

def p1060():
	driver.get('%s?preset=1060' % url)
	time.sleep(1)
	i = 0
	while i < 180:
		save_1('res/%03d.png' % i, 640, 360)
		ActionChains(driver).key_down(Keys.ALT).send_keys(Keys.PAGE_DOWN).key_up(Keys.ALT).perform()
		time.sleep(1)
		i = i + 1

def p1070():
	driver.get('%s?preset=1070' % url)
	time.sleep(1)
	i = 0
	while i < 180:
		save_1('res/%03d.png' % i, 640, 360)
		ActionChains(driver).key_down(Keys.ALT).send_keys(Keys.PAGE_DOWN).key_up(Keys.ALT).perform()
		time.sleep(1)
		i = i + 1

try:
	time.sleep(2)
	#save_2([150, 160], 600, 50)
	#save_2([1033, 1034], 600, 0)
	#save_4(1040, 600)
	save_2([1025, 1026], 600, 0)

except Exception as ex:
	print (ex)

	try:
		driver.close()

	except Exception as ex2:
		print (ex2)

	exit()

try:
	driver.close()

except Exception as ex:
	print (ex)
