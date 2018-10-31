import numpy as np
from PIL import Image
import imageio


# gif动图生成
def create_gif(image_list, gif_name):
    frames = []
    for image_name in image_list:
        frames.append(imageio.imread(image_name))
    imageio.mimsave(gif_name, frames, 'GIF', duration=0.1)

    return

# 读取Imag信息
img1 = Image.open("lena.jpg").convert("RGB")
img2 = Image.open("nobel.jpg").convert("RGB")
image1 = np.array(img1)
height1, width1 = img1.size
image2 = np.array(img2)
height2, width2 = img2.size

#确定中心点
X = int(width2 / 2)
Y = int(height2 / 2)
delta = 0
i = 0


#图片专场像素信息的变化
for delta in range(0, int(height2/2), int(height2/10)):
    for y in range(Y - delta, Y + delta):
        for x in range(X - delta, X + delta):
            if np.power((x - X), 2)+np.power((y - Y), 2) < np.power(delta, 2):
                image2[y][x] = image1[y][x]
    i=i+1
    Image.fromarray(image2).save('circle' + str(i) + '.png')

#gif动图
image_list = ['circle1.png', 'circle2.png', 'circle3.png',
             'circle4.png', 'circle5.png', 'circle6.png']
gif_name = 'circle.gif'
create_gif(image_list, gif_name)

