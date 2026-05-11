#version 440

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    vec2 resolution;
    vec4 accentColor;
    vec4 baseColor;
} ubuf;

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

void main() {
    float aspect = ubuf.resolution.x / max(ubuf.resolution.y, 1.0);
    vec2 p = qt_TexCoord0 * 2.0 - 1.0;
    p.x *= aspect;

    float t = ubuf.time * 0.5;

    float w1 = 0.0;
    w1 += sin(p.x * 2.0 + t * 1.2) * 0.08;
    w1 += sin(p.x * 4.3 + t * 0.7) * 0.05;
    w1 += sin(p.x * 7.1 - t * 1.5) * 0.025;
    w1 += sin(p.x * 13.0 + t * 2.1) * 0.010;
    float frontY = 0.25 + w1;

    float w2 = 0.0;
    w2 += sin(p.x * 1.5 - t * 0.9) * 0.10;
    w2 += sin(p.x * 3.2 + t * 1.1) * 0.06;
    w2 += sin(p.x * 5.5 + t * 0.4) * 0.03;
    w2 += sin(p.x * 11.0 - t * 1.8) * 0.012;
    float backY = 0.00 + w2;

    float frontSea = smoothstep(frontY - 0.003, frontY + 0.003, p.y);
    float backSea = smoothstep(backY - 0.003, backY + 0.003, p.y);

    vec3 sky = ubuf.baseColor.rgb * 0.7;
    vec3 backCol = mix(ubuf.baseColor.rgb, ubuf.accentColor.rgb, 0.35);
    vec3 frontCol = ubuf.accentColor.rgb * 0.55;

    vec3 col = sky;
    col = mix(col, backCol, backSea * 0.85);
    col = mix(col, frontCol, frontSea);

    fragColor = vec4(col, 1.0) * ubuf.qt_Opacity;
}
