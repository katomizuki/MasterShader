Shader "Unlit/fallSnow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
     Tags {
          "Queue"="Transparent"
         "IgnoreProjector"="True"
         "RenderType"="Transparent"
         }
        ZWrite Off
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"

            uniform sampler2D _MainTex;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            float4x4 _PrevInvMatrix;
            float3 _TargetPosition;
            float _Range;
            float _RangeR;
            float _Size;
            float3 _MoveTotal;
            float3 _CamUp;

            v2f vert (appdata v)
            {
                float3 target = _TargetPosition;
                float3 trip;
                float3 mv = v.vertex.xyz;
                mv += _MoveTotal;
                trip = floor(((target - mv) * _RangeR + 1) * 0.5f);
                trip *= (_Range * 2);
                mv += trip;

                float3 diff = _CamUp * _Size;
                float3 finalPosition;
                float3 tv0 = mv;
                tv0.x += sin(mv.x * 0.2) * sin(mv.y * 0.3) * sin(mv.x * 0.9) * sin(mv.y * 0.8);
                tv0.z += sin(mv.x * 0.1) * sin(mv.y * 0.2) * sin(mv.x * 0.8) * sin(mv.y * 1.2);

                float3 eyeVector = ObjSpaceLightDir(float4(tv0, 0));
                float3 sideVector = normalize(cross(eyeVector, diff));
                tv0 += (v.texcoord.x - 0.5f) * sideVector * _Size;
                tv0 += (v.texcoord.y - 0.5f) * diff;
                finalPosition = tv0;

                v2f o;
                o.pos = UnityObjectToClipPos(finalPosition);
                o.uv = MultiplyUV(UNITY_MATRIX_TEXTURE0, v.texcoord);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}
