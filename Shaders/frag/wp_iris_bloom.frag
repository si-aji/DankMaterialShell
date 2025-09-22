// ===== wp_iris_bloom.frag =====
#version 450

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D source1;  // Current wallpaper
layout(binding = 2) uniform sampler2D source2;  // Next wallpaper

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;      // 0.0 -> 1.0
    float centerX;       // 0..1
    float centerY;       // 0..1
    float smoothness;    // 0..1 (edge softness)
    float aspectRatio;   // width / height

    // Fill mode parameters
    float fillMode;      // 0=no(center), 1=crop(fill), 2=fit(contain), 3=stretch
    float imageWidth1;
    float imageHeight1;
    float imageWidth2;
    float imageHeight2;
    float screenWidth;
    float screenHeight;
    vec4  fillColor;
} ubuf;

vec2 calculateUV(vec2 uv, float imgWidth, float imgHeight) {
    vec2 transformedUV = uv;

    if (ubuf.fillMode < 0.5) {
        vec2 screenPixel = uv * vec2(ubuf.screenWidth, ubuf.screenHeight);
        vec2 imageOffset = (vec2(ubuf.screenWidth, ubuf.screenHeight) - vec2(imgWidth, imgHeight)) * 0.5;
        vec2 imagePixel = screenPixel - imageOffset;
        transformedUV = imagePixel / vec2(imgWidth, imgHeight);
    }
    else if (ubuf.fillMode < 1.5) {
        float scale = max(ubuf.screenWidth / imgWidth, ubuf.screenHeight / imgHeight);
        vec2 scaledImageSize = vec2(imgWidth, imgHeight) * scale;
        vec2 offset = (scaledImageSize - vec2(ubuf.screenWidth, ubuf.screenHeight)) / scaledImageSize;
        transformedUV = uv * (vec2(1.0) - offset) + offset * 0.5;
    }
    else if (ubuf.fillMode < 2.5) {
        float scale = min(ubuf.screenWidth / imgWidth, ubuf.screenHeight / imgHeight);
        vec2 scaledImageSize = vec2(imgWidth, imgHeight) * scale;
        vec2 offset = (vec2(ubuf.screenWidth, ubuf.screenHeight) - vec2(scaledImageSize)) * 0.5;
        vec2 screenPixel = uv * vec2(ubuf.screenWidth, ubuf.screenHeight);
        vec2 imagePixel = (screenPixel - offset) / scale;
        transformedUV = imagePixel / vec2(imgWidth, imgHeight);
    }
    // else stretch

    return transformedUV;
}

vec4 sampleWithFillMode(sampler2D tex, vec2 uv, float imgWidth, float imgHeight) {
    vec2 tuv = calculateUV(uv, imgWidth, imgHeight);
    if (tuv.x < 0.0 || tuv.x > 1.0 || tuv.y < 0.0 || tuv.y > 1.0) {
        return ubuf.fillColor;
    }
    return texture(tex, tuv);
}

void main() {
    vec2 uv = qt_TexCoord0;

    vec4 color1 = sampleWithFillMode(source1, uv, ubuf.imageWidth1, ubuf.imageHeight1);
    vec4 color2 = sampleWithFillMode(source2, uv, ubuf.imageWidth2, ubuf.imageHeight2);

    // Edge softness mapping
    float edgeSoft = mix(0.001, 0.45, ubuf.smoothness * ubuf.smoothness);

    // Aspect-corrected coordinates so the iris stays circular
    vec2 center    = vec2(ubuf.centerX, ubuf.centerY);
    vec2 acUv      = vec2(uv.x * ubuf.aspectRatio, uv.y);
    vec2 acCenter  = vec2(center.x * ubuf.aspectRatio, center.y);
    float dist     = length(acUv - acCenter);

    // Max radius needed to cover the screen from the chosen center
    float maxDistX = max(center.x * ubuf.aspectRatio, (1.0 - center.x) * ubuf.aspectRatio);
    float maxDistY = max(center.y, 1.0 - center.y);
    float maxDist  = length(vec2(maxDistX, maxDistY));

    float p = ubuf.progress;
    p = p * p * (3.0 - 2.0 * p);

    float radius = p * maxDist - edgeSoft;

    // Soft circular edge: inside -> color2 (new), outside -> color1 (old)
    float t = smoothstep(radius - edgeSoft, radius + edgeSoft, dist);
    vec4 col = mix(color2, color1, t);

    // Exact snaps at ends
    if (ubuf.progress <= 0.0) col = color1;
    if (ubuf.progress >= 1.0) col = color2;

    fragColor = col * ubuf.qt_Opacity;
}
