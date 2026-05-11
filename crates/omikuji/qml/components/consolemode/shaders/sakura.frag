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

float petal(vec2 uv, vec2 center, float size, float angle, float aspect) {
    vec2 d = uv - center;
    d.x *= aspect;
    float c = cos(angle);
    float s = sin(angle);
    vec2 r = vec2(d.x * c - d.y * s, d.x * s + d.y * c);
    r /= size;

    float rad = length(r);
    if (rad > 1.3) return 0.0;
    float theta = atan(r.x, r.y);

    float profile = pow(max(cos(theta * 0.5), 0.0), 1.6);
    profile -= 0.22 * exp(-theta * theta * 90.0);

    float edge = smoothstep(profile + 0.06, profile - 0.02, rad);
    float body = exp(-rad * rad * 1.5);
    return edge * body;
}

void main() {
    vec2 uv = qt_TexCoord0;
    float aspect = ubuf.resolution.x / max(ubuf.resolution.y, 1.0);

    float t = ubuf.time * 0.14;

    float globalWindX = sin(t * 0.40) * 0.08 + cos(t * 0.23) * 0.04;
    float globalWindY = cos(t * 0.31) * 0.012;

    vec3 col = ubuf.baseColor.rgb * 0.7;
    vec3 petalCol = ubuf.accentColor.rgb * 0.75;
    vec3 highlight = ubuf.accentColor.rgb;

    for (int i = 0; i < 32; i++) {
        float seed = float(i) + 1.0;
        float xBase = hash(seed * 1.31);
        float speedY = 0.030 + hash(seed * 2.71) * 0.035;
        float driftAmp = 0.05 + hash(seed * 3.13) * 0.08;
        float driftFreq = 0.35 + hash(seed * 5.71) * 0.70;
        float phase = hash(seed * 7.13) * 6.28318;
        float size = 0.018 + hash(seed * 11.31) * 0.018;
        float rotSpeed = (hash(seed * 13.7) - 0.5) * 2.4;
        float rotBase = hash(seed * 17.1) * 6.28318;
        float depth = 0.7 + hash(seed * 19.3) * 0.3;

        float py = mod(t * speedY + phase * 0.16, 1.35) - 0.18 + globalWindY;
        float px = xBase + sin(t * driftFreq + phase) * driftAmp + globalWindX * depth;

        float angle = rotBase + t * rotSpeed;

        float glow = petal(uv, vec2(px, py), size, angle, aspect);
        col = mix(col, petalCol, clamp(glow * 0.85 * depth, 0.0, 0.85));

        float core = petal(uv, vec2(px, py), size * 0.55, angle, aspect);
        col = mix(col, highlight, clamp(core * 0.5 * depth, 0.0, 0.5));
    }

    fragColor = vec4(col, 1.0) * ubuf.qt_Opacity;
}
