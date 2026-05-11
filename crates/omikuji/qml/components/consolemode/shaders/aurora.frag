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

float thin(float d, float w) {
    return w / (d + w * 0.3);
}

void main() {
    vec2 p = qt_TexCoord0;
    float t = ubuf.time * 0.08;

    float dx, v = 0.0;

    dx = abs(p.x - (0.06 + sin(p.y * 2.5 + t * 1.5) * 0.06 + sin(p.y * 4.5 + t * 0.9) * 0.025));
    v += thin(dx, 0.0028);

    dx = abs(p.x - (0.18 + sin(p.y * 3.1 - t * 1.3 + 1.1) * 0.07 + sin(p.y * 5.2 - t * 1.0 + 0.7) * 0.03));
    v += thin(dx, 0.0026);

    dx = abs(p.x - (0.31 + sin(p.y * 2.7 + t * 1.7 + 2.3) * 0.08 + sin(p.y * 4.8 - t * 0.8 + 1.4) * 0.03));
    v += thin(dx, 0.003);

    dx = abs(p.x - (0.44 + sin(p.y * 3.4 - t * 1.2 + 0.5) * 0.07 + sin(p.y * 5.5 + t * 1.1 + 2.0) * 0.035));
    v += thin(dx, 0.0028);

    dx = abs(p.x - (0.58 + sin(p.y * 2.9 + t * 1.4 + 3.1) * 0.08 + sin(p.y * 4.2 - t * 1.0 + 0.2) * 0.03));
    v += thin(dx, 0.0026);

    dx = abs(p.x - (0.71 + sin(p.y * 3.2 - t * 1.6 + 1.7) * 0.07 + sin(p.y * 5.1 + t * 0.7 + 2.8) * 0.025));
    v += thin(dx, 0.003);

    dx = abs(p.x - (0.84 + sin(p.y * 3.0 + t * 1.3 + 0.8) * 0.07 + sin(p.y * 4.7 - t * 0.9 + 1.5) * 0.03));
    v += thin(dx, 0.0028);

    dx = abs(p.x - (0.94 + sin(p.y * 2.8 - t * 1.5 + 2.5) * 0.05 + sin(p.y * 4.4 + t * 1.0 + 0.4) * 0.022));
    v += thin(dx, 0.0026);

    float vTop = smoothstep(0.0, 0.03, p.y);
    float vBottom = smoothstep(1.0, 0.95, p.y);
    v *= vTop * vBottom;

    v = clamp(v * 0.35, 0.0, 1.0);

    vec3 col = mix(ubuf.baseColor.rgb * 0.7, ubuf.accentColor.rgb * 0.75, v);

    fragColor = vec4(col, 1.0) * ubuf.qt_Opacity;
}
