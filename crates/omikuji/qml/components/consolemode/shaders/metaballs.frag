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

float hash(float n) { return fract(sin(n) * 43758.5453); }

float metaball(vec2 p, vec2 c, float r) {
    vec2 d = p - c;
    return (r * r) / (dot(d, d) + 0.0001);
}

void main() {
    float aspect = ubuf.resolution.x / max(ubuf.resolution.y, 1.0);
    vec2 p = qt_TexCoord0 * 2.0 - 1.0;
    p.x *= aspect;

    float t = ubuf.time * 0.30;

    float v = 0.0;

    for (int i = 0; i < 18; i++) {
        float fi = float(i) + 1.0;
        float xBase = (hash(fi * 1.31) * 2.0 - 1.0) * 0.95 * aspect;
        float speedY = 0.40 + hash(fi * 2.71) * 0.45;
        float dir = mix(-1.0, 1.0, step(0.30, hash(fi * 4.51)));
        float driftAmp = 0.04 + hash(fi * 3.13) * 0.10;
        float driftFreq = 0.40 + hash(fi * 5.71) * 0.70;
        float phase = hash(fi * 7.13) * 6.28318;
        float r = 0.08 + hash(fi * 11.31) * 0.08;

        float py = mod(t * speedY * dir + phase * 0.41, 4.0) - 2.0;
        float px = xBase + sin(t * driftFreq + phase) * driftAmp;
        float fade = 1.0 - smoothstep(1.4, 1.8, abs(py));

        v += metaball(p, vec2(px, py), r) * fade;
    }

    float mask = smoothstep(0.95, 1.06, v);

    vec3 col = ubuf.baseColor.rgb * 0.65;
    col = mix(col, ubuf.accentColor.rgb, mask);

    float luma = dot(col, vec3(0.299, 0.587, 0.114));
    col = mix(vec3(luma), col, 1.35);

    fragColor = vec4(col, 1.0) * ubuf.qt_Opacity;
}
