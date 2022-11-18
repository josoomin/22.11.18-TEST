Shader "Custom/TestWater"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Opacity ("Opacity", Range(0,1)) = 0.5
        _AnimSpeedX ("Anim Speed (X)", Range(0,4)) = 1.3
        _AnimSpeedY ("Anim Speed (Y)", Range(0,4)) = 2.7
        _AnimScale ("Anim Scale", Range(0,1)) = 0.03
        _AnimTiling ("Anim Tiling", Range(0,20)) = 8
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        LOD 100
        ZWrite Off //물이 가려진 오브젝트를 안보이게 하는 것을 막음
        // depth buffer, z buffer
        // Blend Off : 블렌딩을 끔
        Blend SrcAlpha OneMinusSrcAlpha // 일방적인 투명 설정
        // https://docs.unity3d.com/kr/530/Manual/SL-Blend.html

        Pass
        {
            CGPROGRAM
            //Surface 셰이더와 다르게, 버텍스 셰이더와 프래그먼트셰이더를 직접 쓰겠다는 설정
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            // 위에서 선언한 프로퍼티들과 연결될 셰이더 코드에서 참조하는 변수들 선언
            sampler2D _MainTex;

            // 5개 추가
            half _Opacity;
            float _AnimSpeedX;
            float _AnimSpeedY;
            float _AnimScale;
            float _AnimTiling;

            float4 _MainTex_ST; // 이것은 프로퍼티와 관련없는 셰이더 코드에서만 쓸 변수

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // distort UVs
                // _Time 변수 참고
                // https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
                i.uv.x += sin((i.uv.x + i.uv.y) * _AnimTiling + _Time.y * _AnimSpeedX) * _AnimScale;
                i.uv.y += cos((i.uv.x - i.uv.y) * _AnimTiling + _Time.y * _AnimSpeedY) * _AnimScale;

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);

                //투명도 설정
                col.a = _Opacity;

                return col;
            }
            ENDCG
        }
    }
}