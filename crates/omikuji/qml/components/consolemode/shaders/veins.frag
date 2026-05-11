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

vec2 rand2(vec2 p) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

float veinField(vec2 p, float t) {
    vec2 cell = floor(p);
    vec2 fp = fract(p);

    float f1 = 1e3;
    float f2 = 1e3;

    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 offset = vec2(float(x), float(y));
            vec2 seed = rand2(cell + offset);
            seed = 0.5 + 0.15 * sin(t * 0.5 + 6.28318 * seed);
            vec2 dpos = offset + seed - fp;
            float d = length(dpos);
            if (d < f1) { f2 = f1; f1 = d; }
            else if (d < f2) { f2 = d; }
        }
    }
    return f2 - f1;
}

void main() {
    float aspect = ubuf.resolution.x / max(ubuf.resolution.y, 1.0);
    vec2 p = qt_TexCoord0 * 2.0 - 1.0;
    p.x *= aspect;

    float t = ubuf.time * 0.18;

    vec2 warp = vec2(
        sin(p.y * 1.8 + t * 0.6),
        cos(p.x * 1.6 - t * 0.4)
    ) * 0.18;

    float v = veinField((p + warp) * 3.2, t);

    float glow = smoothstep(0.05, 0.012, v);
    float core = smoothstep(0.02, 0.004, v);

    vec3 col = ubuf.baseColor.rgb * 0.7;
    col = mix(col, ubuf.accentColor.rgb * 0.45, glow * 0.5);
    col = mix(col, ubuf.accentColor.rgb * 0.85, core * 0.65);

    fragColor = vec4(col, 1.0) * ubuf.qt_Opacity;
}
