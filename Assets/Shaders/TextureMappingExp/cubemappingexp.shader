Shader "Unlit/cubemappingexp"
{
    // https://wgld.org/d/webgl/w044.html
    Properties
    {
        [NoScaleOffset] _CubeTex("Cube", Cube) = "" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                half3 normal : NORMALL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 world_pos : TEXCOORD1;
                float3 normal : TEXCOORD2;
            };

            samplerCUBE _CubeTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.world_pos = mul(unity_ObjectToWorld,v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half3 viewDir = _WorldSpaceCameraPos - i.world_pos;
                half3 reflDir = reflect(-1 * viewDir, i.normal);
                half4 refColor = texCUBE(_CubeTex,reflDir);
                return refColor;
            }
            ENDCG
        }
    }
}
